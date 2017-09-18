defmodule SlackCoder.Repo.Migrations.ChangeMessageToText do
  use Ecto.Migration

  def up do
    alter table(:messages) do
      modify :message, :text
    end
  end

  def down do
    alter table(:messages) do
      modify :message, :string, size: 10_000
    end
  end
end
