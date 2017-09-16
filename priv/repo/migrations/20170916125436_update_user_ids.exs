defmodule SlackCoder.Repo.Migrations.UpdateUserIds do
  use Ecto.Migration
  alias SlackCoder.Models.{PR, User}
  alias SlackCoder.Repo
  import Ecto.Query

  def up do
    for user <- Repo.all(User) do
      github = user.github
      from(pr in PR, where: pr.github_user == ^github)
      |> Repo.update_all(set: [user_id: user.id])
    end
    from(pr in PR, where: is_nil(pr.user_id))
    |> Repo.delete_all()
  end

  def down do
    Repo.update_all(PR, set: [user_id: nil])
  end
end
