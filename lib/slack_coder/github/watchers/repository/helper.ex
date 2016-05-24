defmodule SlackCoder.Github.Watchers.Repository.Helper do
  use Timex
  import StubAlias
  alias SlackCoder.Repo
  alias Tentacat.Pulls
  stub_alias Tentacat.Issues.Comments, as: IssueComments
  stub_alias Tentacat.Pulls.Comments, as: PullComments
  stub_alias SlackCoder.Github.Supervisor, as: GithubSupervisor
  alias SlackCoder.Models.{PR, User}
  alias SlackCoder.{Github, Github.Notification, Github.Watchers.PullRequest.Helper}
  import SlackCoder.Github.TimeHelper
  import Ecto.Changeset, only: [put_change: 3]
  require Logger

  def pulls(repo, existing_prs \\ []) do
    me = self
    Task.start fn->
      try do
        send(me, {:pr_response, _pulls(repo, existing_prs)})
      rescue # Rate limiting from Github causes exceptions, until a better solution
        _ -> # within Tentacat presents itself, just log the exception...
          # Logger.error "Error updating Repository info: #{Exception.message(e)}\n#{Exception.format_stacktrace}"
          nil
      end
    end
  end

  defp _pulls(repo, existing_prs) do
    users = Repo.all(User)
            |> Enum.map(&(&1.github))
    owner = Application.get_env(:slack_coder, :repos, [])[repo][:owner]

    Pulls.list(owner, repo, Github.client)
    |> Stream.filter(fn pr ->
          pr["user"]["login"] in users
      end)
    |> Stream.map(fn(pr)->
        Helper.build_or_update(pr, Enum.find(existing_prs, &( &1.number == pr["number"] )))
      end)
    |> Enum.to_list
  end

  def find_latest_comment_date(%PR{number: number, repo: repo, owner: owner} = pr) do
    latest_issue_comment = IssueComments.list(owner, repo, number, Github.client) |> List.last
    latest_pr_comment = PullComments.list(owner, repo, number, Github.client) |> List.last
    case greatest_date_for(latest_issue_comment["updated_at"], latest_pr_comment["updated_at"]) do
      {:first, date} ->
        %{latest_comment: date || pr.opened_at, latest_comment_url: latest_issue_comment["html_url"]}
      {:second, date} ->
        %{latest_comment: date || pr.opened_at, latest_comment_url: latest_pr_comment["html_url"]}
    end
  end

  def handle_closed_pr(changeset = %Ecto.Changeset{}, []), do: changeset
  def handle_closed_pr(changeset = %Ecto.Changeset{}, old_prs) when is_list(old_prs) do
    old_prs
    |> Enum.find(&( &1.number == changeset.data.number))
    |> _handle_closed_pr(changeset)
  end

  defp _handle_closed_pr(nil, cs), do: cs
  defp _handle_closed_pr(pr = %PR{}, cs = %Ecto.Changeset{changes: %{merged_at: merged}}) when not is_nil(merged) do
    cleanup_pr(pr)

    cs
    |> put_change(:notifications, [:merged | cs.changes[:notifications] || cs.data.notifications])
  end
  defp _handle_closed_pr(pr = %PR{}, cs = %Ecto.Changeset{changes: %{closed_at: closed}}) when not is_nil(closed) do
    cleanup_pr(pr)

    cs
    |> put_change(:notifications, [:closed | cs.changes[:notifications] || cs.data.notifications])
  end
  defp _handle_closed_pr(_, cs), do: cs

  defp cleanup_pr(pr) do
    GithubSupervisor.stop_watcher(pr)
    SlackCoder.Endpoint.broadcast("prs:all", "pr:remove", %{pr: pr.number})
  end


  def notifications(pr = %PR{notifications: []}), do: pr
  for type <- [:stale, :unstale, :merged, :closed] do
    def notifications(pr = %PR{notifications: [unquote(type) | notifications]}) do
      %PR{ Notification.unquote(type)(pr) | notifications: notifications} |> notifications
    end
  end

  def build_changeset(params, pr) do
    PR.reg_changeset(pr, params)
  end

  def update_pr(cs) do
    {:ok, pr} = SlackCoder.Services.PRService.save(cs)
    pr
  end

  def stale_notification(cs = %Ecto.Changeset{changes: %{latest_comment: time}}) when not is_nil(time) do
    hours = Date.diff(time, now, :hours)
    if hours >= cs.data.backoff && Notification.can_send_notifications? do
      backoff = next_backoff(cs.data.backoff, hours)
      cs
      |> put_change(:backoff, backoff)
      |> put_change(:notifications, [:stale | cs.changes[:notifications] || cs.data.notifications])
    else
      cs
    end
  end
  def stale_notification(cs), do: cs # Latest comment not available, can't check stale notification

  @backoff Application.get_env(:slack_coder, :pr_backoff_start, 1)
  def unstale_notification(cs = %Ecto.Changeset{changes: %{latest_comment: new_time}, data: %PR{latest_comment: old_time}}) when not (is_nil(new_time) or is_nil(old_time)) do
    if Date.compare(new_time, old_time) != 0 && cs.data.backoff != @backoff do
      cs
      |> put_change(:backoff, @backoff)
      |> put_change(:notifications, [:unstale | cs.changes[:notifications] || cs.data.notifications])
    else
      cs
    end
  end
  def unstale_notification(cs), do: cs # Latest comment not available, can't check unstale notification

  def next_backoff(backoff, greater_than) do
    next_exponent = trunc(:math.log2(backoff) + 1)
    next_notification = trunc(:math.pow(2, next_exponent))
    if next_notification > greater_than do
      next_notification
    else
      next_backoff(next_notification, greater_than)
    end
  end

end
