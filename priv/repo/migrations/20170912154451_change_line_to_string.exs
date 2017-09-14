defmodule SlackCoder.Repo.Migrations.ChangeLineToString do
  use Ecto.Migration

  def up do
    alter table(:random_failures) do
      modify :line, :string
    end
  end

  def down do
    # Nothing to do
  end
end
