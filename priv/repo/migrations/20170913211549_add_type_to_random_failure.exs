defmodule SlackCoder.Repo.Migrations.AddTypeToRandomFailure do
  use Ecto.Migration

  def change do
    alter table(:random_failures) do
      add :type, :string
    end
  end
end
