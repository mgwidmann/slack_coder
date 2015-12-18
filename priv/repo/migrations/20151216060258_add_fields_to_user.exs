defmodule SlackCoder.Repo.Migrations.AddFieldsToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :avatar_url, :string
      add :html_url, :string
    end
  end
end
