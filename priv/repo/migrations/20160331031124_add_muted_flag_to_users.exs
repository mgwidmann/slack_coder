defmodule SlackCoder.Repo.Migrations.AddMutedFlagToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :muted, :boolean, default: false
    end
  end
end
