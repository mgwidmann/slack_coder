defmodule SlackCoder.Github.Watchers.PullRequest do
  use GenServer
  import SlackCoder.Github.Helper

  @poll_interval 60_000 * 2 + 30_000 # Every 2 1/2 minutes

  def start_link(pr) do
    GenServer.start_link __MODULE__, pr
  end

  def init(pr) do
    status(pr) # Async request
    :timer.send_interval @poll_interval, :update_status
    {:ok, pr}
  end

  def handle_info(:update_status, pr) do
    status(pr)
    {:noreply, pr}
  end

  def handle_info({:commit_results, pr}, _old_pr) do
    {:noreply, pr}
  end

  def handle_call(:fetch, _from, pr) do
    {:reply, pr, pr}
  end

  def fetch(:undefined), do: nil

  def fetch(pid) do
    GenServer.call(pid, :fetch)
  end

end
