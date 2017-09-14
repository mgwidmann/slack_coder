defmodule SlackCoder.Repo.Migrations.AddDescriptionToRandomFailure do
  use Ecto.Migration

  def change do
    alter table(:random_failures) do
      add :description, :text
    end
  end
end
