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
    |> put_change(:opened, opened?(changeset))
    |> random_failure()
    |> stale_notification()
    |> unstale_notification()
    |> closed_notification()
    |> merged_notification()
    |> conflict_notification()
    |> successful_notification()
    |> failure_notification()
    |> open_notification()
    |> Repo.insert_or_update()
    |> case do
      {:ok, pr} ->
        {:ok, pr |> check_failed() |> notifications() |> broadcast()}
      errored_changeset ->
        Logger.error "Unable to save PR: #{inspect errored_changeset}"
        errored_changeset
    end
  end

  def open_notification(cs = %Ecto.Changeset{changes: %{opened: true}, data: %PR{opened: false}}) do
    cs |> put_change(:notifications, [:open | cs.changes[:notifications] || cs.data.notifications])
  end
  def open_notification(cs), do: cs

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
    hours = Timex.diff(time, now(), :hours)
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
    if Timex.compare(new_time, old_time) != 0 && cs.data.backoff != @backoff do
      cs
      |> put_change(:backoff, @backoff)
      |> put_change(:notifications, [:unstale | cs.changes[:notifications] || cs.data.notifications])
    else
      cs
    end
  end
  def unstale_notification(cs), do: cs # Latest comment not available, can't check unstale notification

  def conflict_notification(cs = %Ecto.Changeset{changes: %{mergeable: false}, data: %PR{mergeable: mergeable}}) when mergeable in [nil, true] do
    cs
    |> put_change(:build_status, "conflict")
    |> put_change(:notifications, [:conflict | cs.changes[:notifications] || cs.data.notifications])
  end
  def conflict_notification(cs = %Ecto.Changeset{data: %PR{mergeable: false}}) do
    cs
    |> put_change(:build_status, "conflict")
  end
  def conflict_notification(cs), do: cs

  def successful_notification(cs = %Ecto.Changeset{changes: %{build_status: "success"}, data: %PR{build_status: status}}) when status in ["pending", "failure"] do
    cs |> put_change(:notifications, [:success | cs.changes[:notifications] || cs.data.notifications])
  end
  def successful_notification(cs), do: cs

  def failure_notification(cs = %Ecto.Changeset{changes: %{build_status: "failure"}, data: %PR{build_status: status}}) when status in ["pending", "success"] do
    cs
    |> put_change(:last_failed_sha, cs.data.sha)
    |> put_change(:notifications, [:failure | cs.changes[:notifications] || cs.data.notifications])
  end
  def failure_notification(cs), do: cs

  def opened?(%Ecto.Changeset{changes: %{closed_at: closed}}) when not is_nil(closed), do: false
  def opened?(%Ecto.Changeset{changes: %{merged_at: merged}}) when not is_nil(merged), do: false
  def opened?(_cs), do: true

  def next_backoff(backoff, greater_than) do
    next_exponent = trunc(:math.log2(backoff) + 1)
    next_notification = trunc(:math.pow(2, next_exponent))
    if next_notification > greater_than do
      next_notification
    else
      next_backoff(next_notification, greater_than)
    end
  end

  def random_failure(%Ecto.Changeset{changes: %{build_status: "success"} = changes, data: %PR{build_status: "pending", last_failed_sha: sha, sha: sha} = pr} = cs) do
    case changes do
      %{sha: new_sha} when sha != new_sha -> cs # Acceptable case, sha is changed
      _ -> # Sha not changed but status did change
        save_random_failure(pr)
        cs # Return changeset to carry on normally
    end
  end
  def random_failure(cs), do: cs

  def notifications(pr = %PR{notifications: []}), do: pr
  for type <- [:open, :stale, :unstale, :merged, :closed, :conflict, :success, :failure] do
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

  def save_random_failure(pr) do
    Task.start SlackCoder.Services.RandomFailureService, :save_random_failure, [pr]
  end

  def check_failed(pr, attempted_once \\ false)
  def check_failed(%PR{build_status: status} = pr, attempted_once) when status in ~w(failure) do
    case SlackCoder.BuildSystem.failed_jobs(pr) do
      [] ->
        cond do
          attempted_once && SlackCoder.BuildSystem.supported?(pr) ->
            Logger.warn """
            Checking failed job data returned empty twice in a row.

            #{inspect pr, pretty: true}
            """
            load_failed_from_db(pr)
          SlackCoder.BuildSystem.supported?(pr) ->
            check_failed(pr, true)
          true ->
            load_failed_from_db(pr)
        end
      failed_jobs ->
        failed_jobs = if pr.sha == pr.last_failed_sha do # Add together
                        Enum.uniq(pr.last_failed_jobs ++ failed_jobs)
                      else
                        failed_jobs
                      end
        %PR{pr | last_failed_jobs: failed_jobs, last_failed_sha: pr.sha}
    end
  end
  def check_failed(%PR{build_status: status, last_failed_jobs: []} = pr, _attempted_once) when status in ~w(pending) do
    load_failed_from_db(pr)
  end
  def check_failed(pr, _attempted_once), do: pr

  defp load_failed_from_db(pr) do
    case Ecto.assoc(pr, :failure_logs) |> Repo.all() do
      [] -> pr
      [log | _] = failure_logs ->
        failed_jobs = Enum.map(failure_logs, &SlackCoder.BuildSystem.LogParser.parse(&1.log))
        failed_jobs = if pr.sha == log.sha do # Add together
                        Enum.uniq(pr.last_failed_jobs ++ failed_jobs)
                      else
                        failed_jobs
                      end
        %{pr | last_failed_jobs: failed_jobs, last_failed_sha: log.sha}
    end
  end
end
