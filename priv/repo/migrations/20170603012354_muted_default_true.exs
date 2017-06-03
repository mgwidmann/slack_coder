defmodule SlackCoder.Repo.Migrations.MutedDefaultTrue do
  use Ecto.Migration

  def change do
    alter table(:users) do
      modify :muted, :boolean, default: true
    end
  end
end
