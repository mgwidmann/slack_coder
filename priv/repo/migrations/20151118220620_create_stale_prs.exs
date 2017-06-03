defmodule SlackCoder.Repo.Migrations.CreateStalePrs do
  use Ecto.Migration

  def change do
    create table(:stale_prs) do
      add :pr, :string
      add :backoff, :integer, default: Application.get_env(:slack_coder, :pr_backoff_start, 1)
      timestamps()
    end
  end
end
