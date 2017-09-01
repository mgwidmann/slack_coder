defmodule SlackCoder.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :slack, :string
      add :github, :string
      add :config, :map

      timestamps()
    end
    create index :users, [:slack], unique: true
  end
end
