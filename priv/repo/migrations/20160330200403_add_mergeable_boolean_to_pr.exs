defmodule SlackCoder.Repo.Migrations.AddMergeableBooleanToPr do
  use Ecto.Migration

  def change do
    alter table(:prs) do
      add :mergeable, :boolean, default: true
    end
  end
end
