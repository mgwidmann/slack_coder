defmodule SlackCoder.Repo.Migrations.MergeStalePrsWithPrStruct do
  use Ecto.Migration

  def up do
    drop table(:reported_commits)
    drop table(:stale_prs)
    create table(:prs) do
      add :owner, :string
      add :statuses_url, :string
      add :repo, :string
      add :branch, :string
      add :github_user, :string
      # Stale PR checking
      add :latest_comment, :datetime
      add :backoff, :integer
      # Used in view
      add :title, :string
      add :number, :integer
      add :html_url, :string

      timestamps
    end
    create table(:commits) do
      add :sha, :string
      add :latest_status_id, :integer

      add :status, :string
      add :code_climate_status, :string
      add :travis_url, :string
      add :code_climate_url, :string

      add :pr_id, :integer

      timestamps
    end
  end

  def down do
    raise Ecto.MigrationError, message: "Cannot be reversed"
  end
end
