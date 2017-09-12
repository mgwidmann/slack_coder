defmodule SlackCoder.Repo.Migrations.ChangeLineToString do
  use Ecto.Migration

  def change do
    alter table(:random_failures) do
      modify :line, :string
    end
  end
end
