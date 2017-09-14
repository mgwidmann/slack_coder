defmodule SlackCoder.Repo.Migrations.AddJobId do
  use Ecto.Migration

  def up do
    alter table(:random_failures) do
      remove :log_url
      remove :type
      add :external_id, :integer
      add :type, :integer
      add :system, :integer
    end
  end

  def down do
    alter table(:random_failures) do
      add :log_url, :string
      add :type, :string
      remove :external_id
      remove :type
      remove :system
    end
  end
end
