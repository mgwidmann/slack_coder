defmodule SlackCoder.Services.PRService do
  alias SlackCoder.Repo
  alias SlackCoder.Github.Watchers.Repository.Helper
  require Logger

  def save(changeset) do
    changeset
    |> Helper.stale_notification
    |> Helper.unstale_notification
    |> Repo.save
    |> case do
      {:ok, pr} ->
        {:ok, Helper.notifications(pr)}
      errored_changeset ->
        Logger.error "Unable to save PR: #{inspect errored_changeset}"
        errored_changeset
    end
  end
end
