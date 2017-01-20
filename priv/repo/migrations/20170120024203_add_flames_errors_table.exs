defmodule SlackCoder.Repo.Migrations.AddFlamesErrorsTable do
  use Ecto.Migration

  def change do
    # Make sure this table name matches the above configuration
    create table(:errors) do
      add :message, :text
      add :level, :string
      add :timestamp, :utc_datetime # or :utc_datetime if you're using the latest ecto
      add :alive, :boolean
      add :module, :string
      add :function, :string
      add :file, :string
      add :line, :integer
      add :count, :integer
      add :hash, :string

      add :incidents, :json

      timestamps
    end

    create index(:errors, [:hash])
    create index(:errors, [:updated_at])
  end
end
