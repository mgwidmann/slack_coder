defmodule SlackCoder.Services.CommitService do
  alias SlackCoder.Repo
  alias SlackCoder.Github.Notification
  alias SlackCoder.Models.{PR, Commit}
  require Logger

  def save(changeset) do
    case Repo.save(changeset) do
      {:ok, commit} ->
        if changeset.changes[:status] do
          commit
          |> load_pr
          |> broadcast_commit
          |> notify
        end
        {:ok, commit}
      errored_changeset ->
        Logger.error "Unable to save commit: #{inspect errored_changeset}"
        errored_changeset
    end
  end

  def load_pr(commit) do
    pr = Repo.preload commit, :pr
    {commit, pr}
  end

  def broadcast_commit({commit, pr}) do
    pr = %PR{ pr | latest_commit: commit, github_user_avatar: commit.github_user_avatar } # temporary for view only
    html = SlackCoder.PageView.render("pull_request.html", pr: pr)
    SlackCoder.Endpoint.broadcast("prs:all", "pr:update", %{pr: pr.number, github: pr.github_user, html: Phoenix.HTML.safe_to_string(html)})
    {commit, pr}
  end

  def notify({%Commit{status: status}, pr}) when status in ["failure", "error"] do
    Notification.failure(pr)
  end
  def notify({%Commit{status: "success"}, pr}) do
    Notification.success(pr)
  end
  def notify({_, pr}), do: nil # Pending or anything

end
