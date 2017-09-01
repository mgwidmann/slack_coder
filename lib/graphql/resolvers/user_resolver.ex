defmodule SlackCoder.GraphQL.Resolvers.UserResolver do
  @moduledoc """
  """
  alias SlackCoder.Services.UserService
  alias SlackCoder.Models.User
  alias SlackCoder.Repo

  def update(_, %{id: id, user: user_params}, _resolution) do
    case Repo.get(User, id) do
      %User{} = user ->
        User.admin_changeset(user, user_params)
        |> UserService.save()
      nil ->
        {:error, %{not_found: "User #{id} was not found"}}
    end
  end
end
