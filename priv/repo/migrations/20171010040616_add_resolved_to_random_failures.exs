defmodule SlackCoder.Repo.Migrations.AddResolvedToRandomFailures do
  use Ecto.Migration

  def change do
    alter table(:random_failures) do
      add :resolved, :boolean, default: false
    end
  end
end
