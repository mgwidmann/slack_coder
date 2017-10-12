defmodule SlackCoder.Repo.Migrations.AddHiddenFlag do
  use Ecto.Migration

  def change do
    alter table(:prs) do
      add :hidden, :boolean, default: false
    end
  end
end
