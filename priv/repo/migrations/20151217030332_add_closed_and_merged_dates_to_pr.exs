defmodule SlackCoder.Repo.Migrations.AddClosedAndMergedDatesToPr do
  use Ecto.Migration

  def change do
    alter table(:prs) do
      add :closed_at, :utc_datetime
      add :merged_at, :utc_datetime
    end
  end
end
