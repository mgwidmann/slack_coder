defmodule SlackCoder.Services.CommitService do
  alias SlackCoder.Repo
  require Logger

  def save(changeset) do
    case Repo.save(changeset) do
      {:ok, commit} ->
        if changeset.changes[:status] do
          SlackCoder.Github.Helper.report_change(commit)
        end
        {:ok, commit}
      errored_changeset ->
        Logger.error "Unable to save commit: #{inspect errored_changeset}"
        errored_changeset
    end
  end

end
