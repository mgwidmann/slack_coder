defmodule SlackCoder.Repo.Migrations.CreateRandomFailures do
  use Ecto.Migration

  def change do
    create table(:random_failures) do
      add :owner, :string, null: false
      add :repo, :string, null: false
      add :pr, :integer
      add :sha, :string
      add :file, :string, null: false
      add :line, :integer, null: false
      add :seed, :integer
      add :count, :integer, default: 0
      add :log_url, :string

      timestamps()
    end
  end
end
