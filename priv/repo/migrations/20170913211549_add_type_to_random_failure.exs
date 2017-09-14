defmodule SlackCoder.Repo.Migrations.AddTypeToRandomFailure do
  use Ecto.Migration

  def up do
    alter table(:random_failures) do
      add :type, :string
    end
  end

  def down do
    alter table(:random_failures) do
      remove :type
    end
  end
end
