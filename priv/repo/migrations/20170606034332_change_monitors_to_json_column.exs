defmodule SlackCoder.Repo.Migrations.ChangeMonitorsToJsonColumn do
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify :monitors, :varchar
    end
  end
end
