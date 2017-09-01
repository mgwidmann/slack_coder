defmodule SlackCoder.Repo.Migrations.AddReportedCommitsTable do
  use Ecto.Migration

  def change do
    create table(:reported_commits) do
      add :repo, :string
      add :sha, :string
      add :status_id, :integer

      timestamps()
    end
    create index(:reported_commits, [:status_id], unique: true)
  end
end
