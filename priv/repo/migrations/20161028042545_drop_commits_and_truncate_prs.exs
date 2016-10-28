defmodule SlackCoder.Repo.Migrations.DropCommitsAndTruncatePrs do
  use Ecto.Migration

  def change do
    drop table(:commits)
    drop table(:prs)
    create table(:prs) do
      add :owner, :string
      add :repo, :string
      add :title, :string
      add :number, :integer
      add :branch, :string
      add :fork, :boolean
      add :latest_comment, :datetime
      add :latest_comment_url, :string
      add :opened_at, :datetime
      add :closed_at, :datetime
      add :merged_at, :datetime
      add :backoff, :integer
      add :html_url, :string
      add :mergeable, :boolean
      add :github_user, :string
      add :github_user_avatar, :string
      add :sha, :string
      add :build_status, :string
      add :analysis_status, :string
      add :build_url, :string
      add :analysis_url, :string
      add :user_id, :integer
      references :user
      timestamps
    end
  end
end
