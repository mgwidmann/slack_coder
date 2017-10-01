defmodule SlackCoder.GraphQL.Resolvers.UserResolver do
  @moduledoc """
  """
  alias SlackCoder.Services.UserService
  alias SlackCoder.Models.User
  alias SlackCoder.Repo
  import Ecto.Query
  import Absinthe.Resolution.Helpers, only: [batch: 3]

  def list(_, %{search: q} = params, _) do
    query = User.search(q)
    {:ok, Repo.paginate(query, params)}
  end

  def list(_, params, _) do
    {:ok, Repo.paginate(User, params)}
  end

  def update(_, %{id: id, user: user_params}, _resolution) do
    case Repo.get(User, id) do
      %User{} = user ->
        User.admin_changeset(user, user_params)
        |> UserService.save()
      nil ->
        {:error, %{not_found: "User #{id} was not found"}}
    end
  end

  def monitors(user, _params, _info) do
    batch({__MODULE__, :users_by_github}, user.monitors, fn users ->
      {:ok, Map.take(users, user.monitors) |> Map.values()}
    end)
  end

  def users_by_github(_, github_names) do
    github_names = List.flatten(github_names) |> Enum.uniq()
    users = Repo.all User.by_github(github_names)
    Map.new users, fn user -> {user.github, user} end
  end
end
