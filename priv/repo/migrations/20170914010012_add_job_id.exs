defmodule SlackCoder.Repo.Migrations.AddJobId do
  use Ecto.Migration

  def change do
    alter table(:random_failures) do
      remove :log_url
      remove :type
      add :external_id, :integer
      add :type, :integer
      add :system, :integer
    end
  end
end
