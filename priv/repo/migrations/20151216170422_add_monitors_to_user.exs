defmodule SlackCoder.Repo.Migrations.AddMonitorsToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :monitors, :string, default: "[]"
    end
  end
end
