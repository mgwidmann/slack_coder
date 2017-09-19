defmodule SlackCoder.Repo.Migrations.FailedJobs do
  use Ecto.Migration

  def up do
    create table(:failure_logs) do
      add :pr_id, references(:prs, on_delete: :delete_all)
      add :log, :text
      add :external_id, :integer

      timestamps()
    end
    alter table(:random_failures) do
      remove :external_id
      add :failure_log_id, references(:failure_logs)
    end
  end

  def down do
    drop table(:failure_logs)
    alter table(:random_failures) do
      add :external_id, :integer
      remove :failure_log_id
    end
  end
end
