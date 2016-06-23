defmodule SlackCoder.Repo.Migrations.AddFlamesIncidentsTable do
  use Ecto.Migration

  def change do
    create table(:error_incidents) do
      add :error_id, references(:errors)
      add :message, :text
      add :timestamp, :datetime

      timestamps
    end
  end
end
