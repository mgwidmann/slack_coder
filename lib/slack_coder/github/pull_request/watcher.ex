defmodule SlackCoder.Github.PullRequest.Watcher do
  use GenServer
  import SlackCoder.Github.Helper
  alias SlackCoder.Github.PullRequest.Commit
  require Logger

  @poll_interval 60_000

  def start_link(pr) do
    GenServer.start_link __MODULE__, %Commit{pr: pr}
  end

  def init(commit) do
    status(commit) # Async request
    :timer.send_interval @poll_interval, :update_status
    {:ok, commit}
  end

  def handle_info(:update_status, commit) do
    status(commit)
    {:noreply, commit}
  end

  def handle_info({:commit_results, commit}, old_commit) do
    report_status(commit, old_commit)
    {:noreply, commit}
  end

  defp report_status(%Commit{id: id} = commit, %Commit{id: id} = old_commit), do: nil
  defp report_status(commit, _old_commit) do
    case commit.status do
      :failure ->
        message = ":facepalm: *BUILD FAILURE* #{commit.pr.title} :-1:\n#{commit.travis_url}\n#{commit.pr.html_url}"
        Logger.info message
        SlackCoder.Slack.send_to(commit.pr.slack_user, message)
      :success ->
        message = ":bananadance: #{commit.pr.title} :success:"
        Logger.info message
        SlackCoder.Slack.send_to(commit.pr.slack_user, message)
      :pending ->
        nil
    end
    commit
  end

end
