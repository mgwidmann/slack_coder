defmodule SlackCoder.Repo.Migrations.AddForkFlagToPrs do
  use Ecto.Migration

  def up do
    alter table(:prs) do
      add :fork, :boolean, default: false
    end
    execute ~s(UPDATE "prs" AS p0 SET "fork" = true)
  end

  def down do
    alter table(:prs) do
      remove :fork
    end
  end
end
