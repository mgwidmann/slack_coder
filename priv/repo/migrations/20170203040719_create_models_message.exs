defmodule SlackCoder.Repo.Migrations.CreateModels.Message do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :slack, :string
      add :user, :string
      add :message, :text

      timestamps()
    end

  end
end
