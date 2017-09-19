defmodule SlackCoder.Github.Watchers.PullRequest do
  use GenServer
  import StubAlias
  import SlackCoder.Github.TimeHelper
  alias SlackCoder.Models.PR
  stub_alias SlackCoder.Services.UserService
  alias SlackCoder.Services.PRService
  alias SlackCoder.Repo
  import Ecto.Query
  require Logger

  @stale_check_interval 60_000

  def start_link(pr) do
    GenServer.start_link __MODULE__, {pr, []}
  end

  def init({%PR{} = pr, []}) do
    Process.register(self(), :"pr-#{pr.number}") # Will create memory leak for each pr
    send(self(), :init)
    {:ok, {pr, []}}
  end

  def handle_call(:fetch, _from, {pr, callouts}) do
    {:reply, pr, {pr, callouts}}
  end

  def handle_call({:update, raw_pr}, _from, {pr, callouts}) do
    pr = update_pr(raw_pr, pr)
    {:reply, pr, {pr, callouts}}
  end

  def handle_call(_, _, state), do: {:reply, :ignored, state}

  def handle_info(:stale_check, {pr, callouts}) do
    {:ok, pr} = pr |> PR.reg_changeset() |> PRService.save # Sends notification when it is time
    {:noreply, {pr, callouts}}
  end

  def handle_info(:init, {pr, callouts}) do
    # Required in order to give tests the chance to share the connection to this process... If this process executes the query first, test will fail
    unquote(if(Mix.env == :test, do: quote(do: Process.sleep(10))))
    query = PR.by_number(pr.owner, pr.repo, pr.number)
    pr = case Repo.one(query) do
           nil ->
             pr
           existing_pr ->
             existing_pr
         end
    # :timer.send_interval @stale_check_interval, :stale_check
    SlackCoder.Github.ShaMapper.register(pr.sha)
    SlackCoder.Github.Watchers.MergeConflict.queue(pr)
    {:noreply, {pr |> PRService.check_failed(), callouts}}
  end

  def handle_cast({:build, sha, url, state}, {%PR{sha: sha} = pr, callouts}) do
    {:ok, pr} = pr |> PR.reg_changeset(%{build_status: state, build_url: url}) |> PRService.save
    {:noreply, {pr, callouts}}
  end

  def handle_cast({:analysis, sha, url, state}, {%PR{sha: sha} = pr, callouts}) do
    {:ok, pr} = pr |> PR.reg_changeset(%{analysis_status: state, analysis_url: url}) |> PRService.save
    {:noreply, {pr, callouts}}
  end

  def handle_cast({:update, raw_pr}, {old_pr, callouts}) do
    {:noreply, {update_pr(raw_pr, old_pr), callouts}}
  end

  @backoff Application.get_env(:slack_coder, :pr_backoff_start, 1)
  def handle_cast(:unstale, {pr, callouts}) do
    {:ok, updated_pr} = pr |> PR.reg_changeset(%{backoff: @backoff}) |> PRService.save
    {:noreply, {updated_pr, callouts}}
  end

  def handle_cast(message, state) do
    Logger.warn [
      IO.ANSI.green,
      "[", inspect(__MODULE__), "]", IO.ANSI.default_color,
      " Ignoring message received.\nMessage\t\t*** ",
      inspect(message),
      "\nCurrent state\t*** ",
      inspect(state)
    ]
    {:noreply, state}
  end

  defp update_pr(raw_pr, old_pr) do
    {:ok, new_pr} = old_pr |> PR.reg_changeset(extract_pr_data(raw_pr, old_pr)) |> PRService.save
    new_pr
  end

  # When coming in with atom keys, data matches perfectly
  def extract_pr_data(%{owner: _owner} = attrs, _pr) do
    attrs
  end

  def extract_pr_data(raw_pr, pr) do
    %{
      owner: raw_pr["base"]["repo"]["owner"]["login"] || pr.owner,
      repo: raw_pr["base"]["repo"]["name"] || pr.repo,
      branch: raw_pr["head"]["ref"] || pr.branch,
      opened_at: date_for(raw_pr["created_at"]) || pr.opened_at,
      closed_at: date_for(raw_pr["closed_at"]) || pr.closed_at,
      merged_at: date_for(raw_pr["merged_at"]) || pr.merged_at,
      title: raw_pr["title"] || pr.title,
      number: raw_pr["number"] || pr.number,
      html_url: raw_pr["_links"]["html"]["href"] || pr.html_url,
      mergeable: not raw_pr["mergeable_state"] in ["dirty", "conflicting"],
      github_user: raw_pr["user"]["login"] || pr.github_user,
      github_user_avatar: raw_pr["user"]["avatar_url"] || pr.github_user_avatar,
      sha: raw_pr["head"]["sha"] || pr.sha,
      user_id: pr.user_id || user_id(raw_pr["user"]["login"]) || create_user_returning_id(raw_pr["user"]["login"])
    }
    |> mergeable_unknown(raw_pr)
    |> fork_data(raw_pr)
  end

  defp user_id(github) do
    github
    |> SlackCoder.Models.User.by_github()
    |> select([u], u.id)
    |> Repo.one
  end

  defp create_user_returning_id(github) do
    github
    |> Tentacat.Users.find(SlackCoder.Github.client())
    |> UserService.find_or_create_user()
    |> elem(1)
    |> Map.get(:id)
  end

  defp mergeable_unknown(changes, %{"mergeable_state" => "unknown"}) do
    Map.drop(changes, [:mergeable])
  end
  defp mergeable_unknown(changes, _raw_pr), do: changes

  defp fork_data(changes, %{"head" => %{"repo" => %{"owner" => %{"login" => head}}}, "base" => %{"repo" => %{"owner" => %{"login" => base}}}}) do
    Map.put(changes, :fork, head != base)
  end
  defp fork_data(changes, _), do: changes

  def update(pr_pid, pr) when is_pid(pr_pid) do
    GenServer.cast(pr_pid, {:update, pr})
    pr_pid
  end
  def update(_, _), do: nil

  def update_sync(pr_pid, pr) when is_pid(pr_pid) and is_map(pr) do
    GenServer.call(pr_pid, {:update, pr})
  end
  def update_sync(_, _), do: nil

  def unstale(pr_pid) when is_pid(pr_pid) do
    GenServer.cast(pr_pid, :unstale)
    pr_pid
  end
  def unstale(_), do: nil

  def status(pr_pid, type, sha, url, state) when is_pid(pr_pid) and type in [:build, :analysis] do
    GenServer.cast(pr_pid, {type, sha, url, state})
  end
  def status(_, _, _, _, _), do: nil

  def fetch(pid) when is_pid(pid) do
    GenServer.call(pid, :fetch)
  end
  def fetch(_), do: nil

  def last_failed_jobs(pid) when is_pid(pid) do
    %PR{last_failed_jobs: last_failed_jobs} = GenServer.call(pid, :fetch)
    last_failed_jobs
  end
  def last_failed_jobs(_), do: []

end
