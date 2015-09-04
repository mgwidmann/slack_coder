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

  def handle_info({:commit_results, commit}, _old_commit) do
    Logger.debug "Status of PR-#{commit.pr.number} #{String.slice(commit.sha, -8, 8)} #{commit.status}"
    if commit.sha in Dict.keys(commit.reported_shas) do
      if Dict.get(commit.reported_shas, commit.sha) != commit.status do
        commit = report_status(commit)
      end
    else
      commit = report_status(commit)
    end
    {:noreply, commit}
  end

  defp add_reported_sha(commit) do
    %Commit{ commit | reported_shas: Dict.put(commit.reported_shas, commit.sha, commit.status) }
  end

  defp report_status(commit) do
    case commit.status do
      :failure ->
        commit = add_reported_sha(commit)
        message = ":facepalm: *BUILD FAILURE* #{commit.pr.title} :-1:\n#{commit.travis_url}\n#{commit.pr.html_url}"
        Logger.info message
        SlackCoder.Slack.send_to(commit.pr.slack_user, message)
      :success ->
        commit = add_reported_sha(commit)
        message = ":bananadance: #{commit.pr.title} :success:"
        Logger.info message
        SlackCoder.Slack.send_to(commit.pr.slack_user, message)
      :pending ->
        nil
    end
    commit
  end

end
