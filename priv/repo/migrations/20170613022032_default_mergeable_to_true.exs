defmodule SlackCoder.Repo.Migrations.DefaultMergeableToTrue do
  use Ecto.Migration

  def change do
    alter table(:prs) do
      modify :mergeable, :boolean, default: true
    end
    execute("UPDATE prs SET mergeable = true WHERE mergeable = false;")
  end
end
