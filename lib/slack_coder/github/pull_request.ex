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
    unless pr.latest_comment do
      next_exponent = trunc(:math.log2(pr.comment_backoff) + 1)
      next_notification = trunc(:math.pow(2, next_exponent))
      diff = Timex.Date.diff(latest_comment, pr.latest_comment, :hours)
      # At least pr.comment_backoff hours since the latest comment
      if diff > pr.comment_backoff && diff > next_notification do
        comment_backoff = next_notification
        stale_pr_notification(pr, latest_comment)
      end
    end
    %PR{pr | latest_comment: latest_comment, comment_backoff: comment_backoff}
  end

  @weekdays [1,2,3,4,5] |> Enum.map(&Timex.Date.day_name(&1))
  defp stale_pr_notification(pr, latest_comment) do
    now = Timex.Date.local
    day_name = now |> Timex.Date.weekday |> Timex.Date.day_name
    if day_name in @weekdays && now.hour >= 8 && now.hour <= 17 do
      stale_hours = Timex.Date.diff(now, latest_comment, :hours)
      slack_user = SlackCoder.Config.slack_user(pr.github_user)
      message = """
      :hankey: *#{pr.title}*
      Stale for *#{stale_hours}* hours
      #{pr.html_url}
      """
      notify(slack_user, message)
    end
  end

end
