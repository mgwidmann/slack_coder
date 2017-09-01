defmodule SlackCoder.Repo.Migrations.AddOpenedStateToPrs do
  use Ecto.Migration

  def up do
    alter table(:prs) do
      add :opened, :boolean, default: false
    end
    execute "UPDATE prs SET opened = true WHERE closed_at IS NULL AND merged_at IS NULL;"
  end

  def down do
    alter table(:prs) do
      remove :opened
    end
  end
end
