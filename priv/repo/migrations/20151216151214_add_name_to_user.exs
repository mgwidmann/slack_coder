defmodule SlackCoder.Repo.Migrations.AddNameToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :name, :string
    end
    create index :users, [:github], unique: true
  end
end
