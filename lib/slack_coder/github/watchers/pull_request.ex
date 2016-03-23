defmodule SlackCoder.Github.Watchers.PullRequest do
  use GenServer
  import SlackCoder.Github.Helper

  @poll_interval 60_000

  def start_link(pr) do
    GenServer.start_link __MODULE__, {pr, []}
  end

  def init({pr, []}) do
    status(pr) # Async request
    :timer.send_interval @poll_interval, :update_status
    {:ok, {pr, []}}
  end

  def handle_info(:update_status, {pr, _callouts} = state) do
    status(pr)
    {:noreply, state}
  end

  def handle_info({:commit_results, pr}, {_old_pr, callouts}) do
    {:noreply, {pr, callouts}}
  end

  def handle_call(:fetch, _from, {pr, callouts}) do
    {:reply, pr, {pr, callouts}}
  end

  def handle_call({:called_out?, github_user}, _from, {pr, callouts}) do
    {:reply, github_user in callouts, {pr, callouts}}
  end

  def handle_cast({:add_callout, github_user}, {pr, callouts}) do
    {:noreply, {pr, [github_user | callouts] |> Enum.uniq}}
  end

  def add_callout(pr_pid, github_user) do
    GenServer.handle_cast(pr_pid, {:add_callout, github_user})
  end

  def is_called_out?(pr_pid, github_user) do
    GenServer.handle_call(pr_pid, {:called_out?, github_user})
  end

  def fetch(:undefined), do: nil

  def fetch(pid) do
    GenServer.call(pid, :fetch)
  end

end
