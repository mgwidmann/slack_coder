defmodule SlackCoder.Github.Watchers.PullRequest do
  use GenServer
  import SlackCoder.Github.TimeHelper
  alias SlackCoder.Models.PR
  alias SlackCoder.Services.PRService
  alias SlackCoder.Repo

  @stale_check_interval 60_000

  def start_link(pr) do
    GenServer.start_link __MODULE__, {pr, []}
  end

  def init({%PR{} = pr, []}) do
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
    query = PR.by_number(pr.number)
    pr = case Repo.one(query) do
           nil -> pr
           existing_pr -> existing_pr
         end
    :timer.send_interval @stale_check_interval, :stale_check
    SlackCoder.Github.ShaMapper.register(pr.sha)
    {:noreply, {pr, callouts}}
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

  def handle_cast(_, state), do: {:noreply, state}

  defp update_pr(raw_pr, old_pr) do
    {:ok, new_pr} = old_pr |> PR.reg_changeset(extract_pr_data(raw_pr)) |> PRService.save
    new_pr
  end

  def extract_pr_data(raw_pr) do
    %{
      owner: raw_pr["base"]["repo"]["owner"]["login"],
      repo: raw_pr["base"]["repo"]["name"],
      branch: raw_pr["head"]["ref"],
      fork: raw_pr["head"]["repo"]["owner"]["login"] != raw_pr["base"]["repo"]["owner"]["login"],
      latest_comment: nil,
      latest_comment_url: nil,
      opened_at: date_for(raw_pr["created_at"]),
      closed_at: date_for(raw_pr["closed_at"]),
      merged_at: date_for(raw_pr["merged_at"]),
      title: raw_pr["title"],
      number: raw_pr["number"],
      html_url: raw_pr["_links"]["html"]["href"],
      mergeable: raw_pr["mergeable_state"] == "mergeable" && raw_pr["mergeable_state"] != "unknown",
      github_user: raw_pr["user"]["login"],
      github_user_avatar: raw_pr["user"]["avatar_url"],
      sha: raw_pr["head"]["sha"]
    }
  end

  def update(pr_pid, pr) when is_pid(pr_pid) do
    GenServer.cast(pr_pid, {:update, pr})
    pr_pid
  end
  def update(_, _), do: nil

  def update_sync(pr_pid, pr) when is_pid(pr_pid) do
    GenServer.call(pr_pid, {:update, pr})
  end
  def update_sync(_, _), do: nil

  def unstale(pr_pid) when is_pid(pr_pid) do
    GenServer.cast(pr_pid, :unstale)
    pr_pid
  end
  def unstale(_), do: nil

  def status(pr_pid, type, sha, url, state) when is_pid(pr_pid) do
    GenServer.cast(pr_pid, {type, sha, url, state})
  end
  def status(_, _, _, _, _), do: nil

  def fetch(pid) when is_pid(pid) do
    GenServer.call(pid, :fetch)
  end
  def fetch(_), do: nil

end
