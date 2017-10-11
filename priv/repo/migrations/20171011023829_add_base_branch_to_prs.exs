defmodule SlackCoder.Repo.Migrations.AddBaseBranchToPrs do
  use Ecto.Migration

  def change do
    alter table(:prs) do
      add :base_branch, :string
    end
  end
end
