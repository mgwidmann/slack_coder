defmodule SlackCoder.UserController do
  use SlackCoder.Web, :controller

  plug :scrub_params, "user" when action in [:create, :update]

  def new(conn, _params) do
    user = conn.assigns.current_user
    changeset = User.changeset(user)
    render(conn, "user.html", user: user, changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    user = conn.assigns.current_user
    changeset = User.changeset(user, Map.put(user_params, "config", SlackCoder.Users.Help.default_config))

    case Repo.insert(changeset) do
      {:ok, user} ->
        SlackCoder.Users.Supervisor.start_user(user)
        conn
        |> put_session(:current_user, user)
        |> redirect(to: "/")
      {:error, changeset} ->
        render(conn, "user.html", user: user, changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user)
    render(conn, "user.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        SlackCoder.Users.Supervisor.start_user(user)
        conn
        |> put_session(:current_user, user)
        |> redirect(to: "/")
      {:error, changeset} ->
        render(conn, "user.html", user: user, changeset: changeset)
    end
  end

end
