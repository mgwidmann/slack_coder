defmodule SlackCoder.Github.Watchers.PullRequest do
  use GenServer
  import SlackCoder.Github.Watchers.PullRequest.Helper
  alias SlackCoder.Models.PR
  alias SlackCoder.Services.PRService
  alias SlackCoder.Repo

  @stale_check_interval 60_000

  def start_link(pr) do
    GenServer.start_link __MODULE__, {pr, []}
  end

  def init({%PR{} = pr, []}) do
    query = PR.by_number(pr.number)
    pr = case Repo.one(query) do
           nil -> pr
           existing_pr -> existing_pr
         end
    :timer.send_interval @stale_check_interval, :stale_check
    {:ok, {pr, []}}
  end

  # def init({pr, []}) do
  #   status(pr) # Async request
  #   :timer.send_interval @stale_check_interval, :update_status
  #   {:ok, {pr, []}}
  # end
  #
  # def handle_info(:update_status, {pr, _callouts} = state) do
  #   status(pr)
  #   {:noreply, state}
  # end
  #
  # def handle_info({:commit_results, pr}, {_old_pr, callouts}) do
  #   {:noreply, {pr, callouts}}
  # end

  def handle_call(:fetch, _from, {pr, callouts}) do
    {:reply, pr, {pr, callouts}}
  end

  def handle_call({:update, raw_pr, nil}, _from, {pr, callouts}) do
    pr = update_pr(raw_pr, pr)
    {:reply, pr, {pr, callouts}}
  end

  # def handle_call({:called_out?, github_user}, _from, {pr, callouts}) do
  #   {:reply, github_user in callouts, {pr, callouts}}
  # end
  #
  # def handle_cast({:add_callout, github_user}, {pr, callouts}) do
  #   {:noreply, {pr, [github_user | callouts] |> Enum.uniq}}
  # end

  def handle_cast(:stale_check, {pr, callouts}) do
    pr |> PR.reg_changeset() |> PRService.save # Sends notification when it is time
    {:noreply, {pr, callouts}}
  end

  def handle_cast({:update, raw_pr, nil}, {old_pr, callouts}) do
    {:noreply, {update_pr(raw_pr, old_pr), callouts}}
  end

  def handle_cast({:update, raw_pr, raw_commit}, {old_pr, callouts}) do
    new_pr = update_pr(raw_pr, old_pr)

    {travis, codeclimate} = statuses_for_commit(new_pr, raw_commit["sha"])

    params = build_params(new_pr, raw_commit, travis, codeclimate)
    commit = new_pr
             |> find_latest_commit(travis["id"], raw_commit["sha"])
             |> update_commit(params)

    {:noreply, {%PR{ new_pr | latest_commit: commit}, callouts}}
  end

  @backoff Application.get_env(:slack_coder, :pr_backoff_start, 1)
  def handle_cast(:unstale, {pr, callouts}) do
    {:ok, updated_pr} = pr |> PR.reg_changeset(%{backoff: @backoff}) |> PRService.save
    {:noreply, {updated_pr, callouts}}
  end

  defp update_pr(raw_pr, old_pr) do
    raw_pr
    |> build_or_update(old_pr)
    |> conflict_notification(old_pr)
  end

  # def add_callout(pr_pid, github_user) do
  #   GenServer.cast(pr_pid, {:add_callout, github_user})
  # end
  #
  # def is_called_out?(:undefined, _github_user), do: false
  # def is_called_out?(pr_pid, github_user) do
  #   GenServer.call(pr_pid, {:called_out?, github_user})
  # end

  def update(pr_pid, pr, commit \\ nil)
  def update(nil, _, _), do: nil
  def update(pr_pid, pr, commit) do
    GenServer.cast(pr_pid, {:update, pr, commit})
    pr_pid
  end

  def update_sync(nil, _), do: nil
  def update_sync(pr_pid, pr) do
    GenServer.call(pr_pid, {:update, pr, nil})
  end

  def unstale(:undefined), do: nil
  def unstale(pr_pid) do
    GenServer.cast(pr_pid, :unstale)
    pr_pid
  end

  def fetch(:undefined), do: nil
  def fetch(pid) do
    GenServer.call(pid, :fetch)
  end

end
