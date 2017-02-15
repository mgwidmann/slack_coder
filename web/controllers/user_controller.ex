defmodule SlackCoder.UserController do
  use SlackCoder.Web, :controller

  plug :scrub_params, "user" when action in [:create, :update]
  @page_size 25

  def index(conn, params) do
    users = User |> Repo.paginate(params |> Map.put("page_size", @page_size))
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    user = conn.assigns.current_user
    changeset = User.changeset(user)
    render(conn, "user.html", user: user, changeset: changeset)
  end

  def external(conn, %{"github" => github}) do
    user = user_for_github(github)
    changeset = User.admin_changeset(user, %{muted: true})
    render(conn, "user.html", user: user, changeset: changeset)
  end

  def create_external(conn, %{"user" => user_params, "github" => github}) do
    user = user_for_github(github)
    changeset = User.admin_changeset(user, Map.put(user_params, "muted", true))
    conn
    |> create_user(user, changeset, false)
  end

  def create(conn, %{"user" => user_params}) do
    user = conn.assigns.current_user
    changeset = User.changeset(user, user_params)
    conn
    |> create_user(user, changeset, true)
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
        |> put_session(:current_user, conn.assigns[:current_user] || user)
        |> redirect(to: "/")
      {:error, changeset} ->
        render(conn, "user.html", user: user, changeset: changeset)
    end
  end

  def messages(conn, params) do
    messages = Message |> Repo.paginate(params |> Map.put("page_size", @page_size))
    avatars = from(u in User, select: %{u.slack => u.avatar_url}) |> Repo.all |> Enum.reduce(%{}, &Map.merge/2)
    render(conn, "messages.html", messages: messages, avatars: avatars)
  end

  defp create_user(conn, user, changeset, setup_session) do
    changeset = Ecto.Changeset.put_embed changeset, :config, SlackCoder.Users.Help.default_config

    case Repo.insert(changeset) do
      {:ok, user} ->
        SlackCoder.Users.Supervisor.start_user(user)

        if(setup_session, do: put_session(conn, :current_user, user), else: conn)
        |> redirect(to: "/")
      {:error, changeset} ->
        render(conn, "user.html", user: user, changeset: changeset)
    end
  end

  defp user_for_github(github) do
    github_user = Tentacat.Users.find github, SlackCoder.Github.client
    %User{github: github, name: github_user["name"], html_url: github_user["html_url"], avatar_url: github_user["avatar_url"]}
  end

end
