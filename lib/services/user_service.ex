defmodule SlackCoder.Services.UserService do
  import Ecto.Query

  alias SlackCoder.{Repo, Models.User}

  def find_or_create_user(raw_user) do
    %{github: github} = simplified_user = %{name: raw_user["name"], github: raw_user["login"], avatar_url: raw_user["avatar_url"], html_url: raw_user["html_url"], config: %{}}
    db_user = from(u in User, where: u.github == ^github) |> Repo.one

    simplified_user = if db_user == nil || match?(%User{slack: nil}, db_user), do: Map.merge(simplified_user, %{slack: raw_user["login"]}), else: simplified_user

    user = simplified_user |> update_user(db_user)
    SlackCoder.Users.Supervisor.start_user(user)
    if db_user, do: {:ok, user}, else: {:new, user}
  end

  defp update_user(user, db_user) do
    User.changeset(db_user || %User{}, user) |> Repo.insert_or_update!
  end
end
