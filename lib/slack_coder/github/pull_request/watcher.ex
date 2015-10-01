defmodule SlackCoder.Github.PullRequest.Watcher do
  use GenServer
  import SlackCoder.Github.Helper
  alias SlackCoder.Github.PullRequest.Commit
  alias SlackCoder.Repo
  alias SlackCoder.Models.ReportedCommit
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

  def handle_call(:fetch, _from, last_commit) do
    {:reply, last_commit, last_commit}
  end

  def fetch(:undefined), do: nil

  def fetch(pid) do
    GenServer.call(pid, :fetch)
  end

  defp report_status(%Commit{id: id} = _commit, %Commit{id: id} = _old_commit), do: nil
  defp report_status(commit, _old_commit) do
    unless reported?(commit) do
      %ReportedCommit{}
      |> ReportedCommit.changeset(%{
        repo: "#{commit.pr.owner}/#{commit.pr.repo}",
        sha: commit.sha,
        status_id: commit.id,
        status: to_string(commit.status),
        github_user: to_string(commit.github_user),
        pr: to_string(commit.pr.number)
      })
      |> Repo.insert

      {:safe, html} = SlackCoder.PageView.render("pull_request.html", commit: commit)
      case SlackCoder.Endpoint.broadcast("prs:all", "pr:update", %{pr: commit.pr.number, html: :erlang.iolist_to_binary(html)}) do
        :ok -> nil
        error ->
          Logger.error "Error broadcasting pr:update -- #{inspect error}"
      end


      case commit.status do
        status when status in [:failure, :error] ->
          message = ":facepalm: *BUILD FAILURE* #{commit.pr.title} :-1:\n#{commit.travis_url}\n#{commit.pr.html_url}"
          Logger.info message
          SlackCoder.Slack.send_to(commit.pr.slack_user, message)
        :success ->
          message = ":bananadance: #{commit.pr.title} :success:"
          Logger.info message
          SlackCoder.Slack.send_to(commit.pr.slack_user, message)
        # :pending or ignoring any other unknown statuses
        _ ->
          nil
      end
    end
    commit
  end

  def reported?(%Commit{id: nil}), do: true # Will cause an error if we attempt to insert
  def reported?(commit) do
    Repo.get_by(ReportedCommit, status_id: commit.id)
  end

end
