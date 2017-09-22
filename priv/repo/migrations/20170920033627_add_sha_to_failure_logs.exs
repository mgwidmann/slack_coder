defmodule SlackCoder.Repo.Migrations.AddShaToFailureLogs do
  use Ecto.Migration

  def up do
    alter table(:failure_logs) do
      add :sha, :string
    end
  end

  def down do
    alter table(:failure_logs) do
      remove :sha
    end
  end
end
