defmodule SlackCoder.Repo.Migrations.AddUserToReportedCommits do
  use Ecto.Migration

  def change do
    alter table(:reported_commits) do
      add :github_user, :string
      add :pr, :string
    end
  end
end
