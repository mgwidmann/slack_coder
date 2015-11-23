defmodule SlackCoder.Repo.Migrations.MergeStalePrsWithPrStruct do
  use Ecto.Migration

  def up do
    drop_if_exists table(:reported_commits)
    drop_if_exists table(:stale_prs)
    create table(:prs) do
      add :owner, :string
      add :statuses_url, :string
      add :repo, :string
      add :branch, :string
      add :github_user, :string
      # Stale PR checking
      add :latest_comment, :datetime
      add :backoff, :integer, default: Application.get_env(:slack_coder, :pr_backoff_start, 1)
      add :opened_at, :datetime
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
    drop_if_exists table(:prs)
    drop_if_exists table(:commits)
  end
end
