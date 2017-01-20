defmodule SlackCoder.Services.PRService do
  use Timex
  alias SlackCoder.Repo
  alias SlackCoder.Github.Notification
  alias SlackCoder.Models.PR
  alias SlackCoder.PageView
  alias SlackCoder.Endpoint
  import Ecto.Changeset, only: [put_change: 3, get_change: 2]
  import SlackCoder.Github.TimeHelper
  require Logger

  def save(changeset) do
    changeset
    |> stale_notification()
    |> unstale_notification()
    |> closed_notification()
    |> merged_notification()
    |> conflict_notification()
    |> successful_notification()
    |> failure_notification()
    |> Repo.insert_or_update()
    |> case do
      {:ok, pr} ->
        {:ok, pr |> notifications() |> broadcast()}
      errored_changeset ->
        Logger.error "Unable to save PR: #{inspect errored_changeset}"
        errored_changeset
    end
  end

  def merged_notification(cs = %Ecto.Changeset{changes: %{merged_at: time}}) when not is_nil(time) do
    cs |> put_change(:notifications, [:merged | cs.changes[:notifications] || cs.data.notifications])
  end
  def merged_notification(cs) do
    cs
  end

  def closed_notification(cs = %Ecto.Changeset{changes: %{closed_at: time}}) when not is_nil(time) do
    if get_change(cs, :merged_at) do # Both are present when things get merged
      cs
    else
      cs |> put_change(:notifications, [:closed | cs.changes[:notifications] || cs.data.notifications])
    end
  end
  def closed_notification(cs), do: cs

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

  def conflict_notification(cs = %Ecto.Changeset{changes: %{mergeable: false}, data: %PR{mergeable: true}}) do
    cs |> put_change(:notifications, [:conflict | cs.changes[:notifications] || cs.data.notifications])
  end
  def conflict_notification(cs), do: cs

  def successful_notification(cs = %Ecto.Changeset{changes: %{build_status: "success"}, data: %PR{build_status: status}}) when status in ["pending", "failure"] do
    cs |> put_change(:notifications, [:success | cs.changes[:notifications] || cs.data.notifications])
  end
  def successful_notification(cs), do: cs

  def failure_notification(cs = %Ecto.Changeset{changes: %{build_status: "failure"}, data: %PR{build_status: status}}) when status in ["pending", "success"] do
    cs |> put_change(:notifications, [:failure | cs.changes[:notifications] || cs.data.notifications])
  end
  def failure_notification(cs), do: cs

  def next_backoff(backoff, greater_than) do
    next_exponent = trunc(:math.log2(backoff) + 1)
    next_notification = trunc(:math.pow(2, next_exponent))
    if next_notification > greater_than do
      next_notification
    else
      next_backoff(next_notification, greater_than)
    end
  end

  def notifications(pr = %PR{notifications: []}), do: pr
  for type <- [:stale, :unstale, :merged, :closed, :conflict, :success, :failure] do
    def notifications(pr = %PR{notifications: [unquote(type) | notifications]}) do
      %PR{ Notification.unquote(type)(pr) | notifications: notifications} |> notifications
    end
  end

  def broadcast(%PR{closed_at: closed, merged_at: merged} = pr) when not is_nil(closed) or not is_nil(merged) do
    Endpoint.broadcast("prs:all", "pr:remove", %{pr: pr.number})
    pr
  end
  def broadcast(pr) do
    html = PageView.render("pull_request.html", pr: pr)
    Endpoint.broadcast("prs:all", "pr:update", %{pr: pr.number, github: pr.github_user, html: Phoenix.HTML.safe_to_string(html)})
    pr
  end
end
