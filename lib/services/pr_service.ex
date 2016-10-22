defmodule SlackCoder.Services.PRService do
  alias SlackCoder.Repo
  alias SlackCoder.Github.Watchers.Repository.Helper
  require Logger

  def save(changeset) do
    changeset
    |> Helper.stale_notification()
    |> Helper.unstale_notification()
    |> Helper.closed_notification()
    |> Helper.merged_notification()
    |> Repo.insert_or_update()
    |> case do
      {:ok, pr} ->
        {:ok, Helper.notifications(pr)}
      errored_changeset ->
        Logger.error "Unable to save PR: #{inspect errored_changeset}"
        errored_changeset
    end
  end
end
