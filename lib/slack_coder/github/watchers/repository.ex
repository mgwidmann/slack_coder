defmodule SlackCoder.Github.Watchers.Repository do
  use GenServer
  import SlackCoder.Github.Helper
  alias SlackCoder.Models.PR
  import Ecto.Changeset, only: [put_change: 3]
  use Timex
  require Logger
  alias SlackCoder.Repo

  @poll_minutes 5
  @poll_interval 60_000 * @poll_minutes # 5 minutes

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
    prs = prs |> Enum.map(fn(pr)->
      {pr, send_notification} = find_latest_comment(pr) |> stale_pr
      if send_notification, do: stale_pr_notification(pr)
      pr
    end)
    {:noreply, {repo, prs}}
  end

  def handle_info(:update_prs, {repo, existing_prs}) do
    pulls(repo, existing_prs)
    # State doesn't change until :pr_response message is received
    {:noreply, {repo, existing_prs}}
  end

  def poll_minutes(), do: @poll_minutes

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
        [message_for | slack_users] = slack_user_with_monitors(pr)
        response = get("repos/#{pr.owner}/#{pr.repo}/pulls/#{pr.number}")
        merged = response["merged"] || response["merged_at"] != nil
        PR.changeset(pr, %{merged_at: response["merged_at"], closed_at: response["closed_at"]})
          |> Repo.update
        if merged do
          message = """
          :smiling_imp: _MERGED_ *#{pr.title}* :raveparrot:
          #{pr.html_url}
          """
          notify(slack_users, :merge, message_for, message)
        else
          message = """
          :rage: _CLOSED_ *#{pr.title}*
          #{pr.html_url}
          """
          notify(slack_users, :close, message_for, message)
        end
      end
    end
  end

  def stale_pr(cs) do
    latest_comment = cs.model.latest_comment # Original
    pr_latest_comment = cs.changes[:latest_comment] || latest_comment # Updated
    hours = Date.diff(latest_comment, now, :hours)
    if hours >= cs.model.backoff && can_send_notifications? do
      backoff = next_backoff(cs.model.backoff, hours)
      cs = put_change(cs, :backoff, backoff)
      send_notification = true
    end
    if Date.compare(latest_comment, pr_latest_comment) != 0 do
      cs = put_change(cs, :backoff, Application.get_env(:slack_coder, :pr_backoff_start, 1))
    end
    {:ok, pr} = SlackCoder.Repo.save(cs)
    {pr, send_notification}
  end

  def next_backoff(backoff, greater_than) do
    next_exponent = trunc(:math.log2(backoff) + 1)
    next_notification = trunc(:math.pow(2, next_exponent))
    if next_notification > greater_than do
      next_notification
    else
      next_backoff(next_notification, greater_than)
    end
  end

  defp stale_pr_notification(pr) do
    stale_hours = Timex.Date.diff(pr.latest_comment, now, :hours)
    [message_for | slack_users] = slack_user_with_monitors(pr)
    message = """
    :hankey: *#{pr.title}*
    Stale for *#{stale_hours}* hours
    #{pr.html_url}
    """
    notify(slack_users, :stale, message_for, message)
  end

end
