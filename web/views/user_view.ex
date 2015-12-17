defmodule SlackCoder.UserView do
  use SlackCoder.Web, :view

  def new_or_update_user_path(conn, %{id: nil}) do
    user_path(conn, :create)
  end
  def new_or_update_user_path(conn, user) do
    user_path(conn, :update, user)
  end

  def users_list(except) do
    SlackCoder.Users.Supervisor.users
    |> Enum.reject(fn(user)->
        user.github == except
    end)
    |> Enum.map(fn(user)->
      {"#{user.name} (#{user.github})", user.github}
    end)
  end
end
