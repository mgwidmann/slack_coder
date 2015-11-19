defmodule SlackCoder.Github.PullRequest do
  use GenServer
  import SlackCoder.Github.Helper
  alias SlackCoder.Github.PullRequest.PR
  require Logger

  @poll_interval 60_000 * 5 # 5 minutes

  def start_link(repo) do
    GenServer.start_link __MODULE__, repo
  end

  def init(repo) do
    pulls(repo) # Async fetch
    :timer.send_interval @poll_interval, :update_prs
    {:ok, {repo, []}}
  end

  def handle_info({:pr_response, prs}, {repo, old_prs}) do
    prs # new prs start watchers for each
    |> Enum.each(&SlackCoder.Github.Supervisor.start_watcher(&1))
    close_prs(prs, old_prs)
    prs = prs
          |> Enum.map(&(stale_pr(&1)))
    {:noreply, {repo, prs}}
  end

  def handle_info(:update_prs, {repo, existing_prs}) do
    pulls(repo, existing_prs)
    # State doesn't change until :pr_response message is received
    {:noreply, {repo, existing_prs}}
  end

  defp close_prs(_new_prs, []), do: nil
  defp close_prs(new_prs, old_prs) do
    closed_prs =  (old_prs |> Enum.map(&(&1.number))) -- (new_prs |> Enum.map(&(&1.number)))
    if closed_prs != [] do
      Logger.debug "Closed PRs: #{inspect closed_prs}"
      Enum.each closed_prs, fn(pr_number)->
        pr = Enum.find(old_prs, &( &1.number == pr_number))
        Logger.debug "Stopping watcher for: PR-#{pr.number} #{pr.title}"
        SlackCoder.Github.Supervisor.stop_watcher(pr)
        SlackCoder.Endpoint.broadcast("prs:all", "pr:remove", %{pr: pr.number})
      end
    end
  end

  defp stale_pr(pr) do
    latest_comment = find_latest_comment(pr)
    comment_backoff = pr.comment_backoff
    if pr.latest_comment == nil && latest_comment == nil do
      latest_comment = Timex.DateTime.local
    end
    if should_send_notification?(pr, latest_comment) && can_send_notification?() do
      comment_backoff = next_backoff(pr)
      stale_pr_notification(pr, latest_comment)
    end
    %PR{pr | latest_comment: latest_comment, comment_backoff: comment_backoff}
  end

  @weekdays [1,2,3,4,5] |> Enum.map(&Timex.Date.day_name(&1))
  defp can_send_notification?() do
    now = Timex.Date.now
    hour = now.hour + Application.get_env(:slack_coder, :timezone_offset)
    day_name = now |> Timex.Date.weekday |> Timex.Date.day_name
    day_name in @weekdays && hour >= 8 && hour <= 17
  end

  defp should_send_notification?(pr, latest_comment) do
    next_notification = next_backoff(pr)
    if latest_comment && pr.latest_comment do
      diff = Timex.Date.diff(latest_comment, pr.latest_comment, :hours)
    end
    # At least pr.comment_backoff hours since the latest comment or no comments
    not already_reported?(pr) && (diff == nil || (diff > pr.comment_backoff && diff > next_notification))
  end

  defp already_reported?(pr) do
    stale_pr = SlackCoder.Repo.get_by(SlackCoder.Models.StalePR, pr: to_string(pr.number))
    stale_pr[:backoff] >= pr.comment_backoff
  end

  defp next_backoff(pr) do
    next_exponent = trunc(:math.log2(pr.comment_backoff) + 1)
    next_notification = trunc(:math.pow(2, next_exponent))
    next_notification
  end

  defp stale_pr_notification(pr, latest_comment) do
    now = Timex.Date.now
    stale_hours = Timex.Date.diff(latest_comment, now, :hours)
    slack_user = SlackCoder.Config.slack_user(pr.github_user)
    stale_pr = SlackCoder.Repo.get_by(SlackCoder.Models.StalePR, pr: to_string(pr.number))
    SlackCoder.Repo.save SlackCoder.Models.StalePR.changeset(stale_pr || %SlackCoder.Models.StalePR{}, %{pr: to_string(pr.number), backoff: pr.comment_backoff})
    message = """
    :hankey: *#{pr.title}*
    Stale for *#{stale_hours}* hours
    #{pr.html_url}
    """
    notify(slack_user, message)
  end

end
