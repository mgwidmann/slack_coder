defmodule SlackCoder.Repo.Migrations.AddClosedAndMergedDatesToPr do
  use Ecto.Migration

  def change do
    alter table(:prs) do
      add :closed_at, :datetime
      add :merged_at, :datetime
    end
  end
end
