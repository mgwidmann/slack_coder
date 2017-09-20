defmodule SlackCoder.Repo.Migrations.UpdateShasOnFailure_Logs do
  use Ecto.Migration

  def up do
    for log <- SlackCoder.Models.RandomFailure.FailureLog |> SlackCoder.Repo.all() do
      case Ecto.assoc(log, :pr) |> SlackCoder.Repo.one do
        %SlackCoder.Models.PR{build_status: "failure", sha: sha} ->
          SlackCoder.Repo.update SlackCoder.Models.RandomFailure.FailureLog.changeset(log, %{sha: sha})
        o ->
          nil
      end
    end
  end

  def down do
    SlackCoder.Repo.update_all(SlackCoder.Models.RandomFailure.FailureLog, set: [sha: nil])
  end
end
