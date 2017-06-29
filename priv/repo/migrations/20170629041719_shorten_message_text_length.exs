defmodule SlackCoder.Repo.Migrations.ShortenMessageTextLength do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      modify :message, :string, size: 10_000
    end
  end
end
