defmodule SlackCoder.Repo.Migrations.CreateFlamesTable do
  use Ecto.Migration

  def change do
    create table(:errors) do
      add :message, :text
      add :level, :string
      add :timestamp, :datetime
      add :alive, :boolean
      add :module, :string
      add :function, :string
      add :file, :string
      add :line, :integer
      add :count, :integer
      add :hash, :string

      timestamps
    end

    create index(:errors, [:hash])
  end
end
