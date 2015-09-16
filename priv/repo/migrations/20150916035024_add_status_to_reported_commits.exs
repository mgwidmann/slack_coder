defmodule SlackCoder.Repo.Migrations.AddStatusToReportedCommits do
  use Ecto.Migration

  def change do
    alter table(:reported_commits) do
      add :status, :string
    end
  end
end
