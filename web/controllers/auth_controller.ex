defmodule SlackCoder.AuthController do
  use SlackCoder.Web, :controller

  @doc """
  This action is reached via `/auth/:provider` and redirects to the OAuth2 provider
  based on the chosen strategy.
  """
  def index(conn, %{"provider" => "github"}) do
    redirect conn, external: authorize_url!
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  @doc """
  This action is reached via `/auth/:provider/callback` is the the callback URL that
  the OAuth2 provider will redirect the user back to with a `code` that will
  be used to request an access token. The access token will then be used to
  access protected resources on behalf of the user.
  """
  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: %Ueberauth.Auth{extra:
      %Ueberauth.Auth.Extra{raw_info: %{token: %{access_token: token}, user: raw_user}}}}} = conn, _params) do
    case raw_user |> find_or_create_user() do
      {:ok, db_user} ->
        conn
        |> after_login(db_user)
        |> redirect(to: "/")
      {:new, db_user} ->
        conn
        |> after_login(db_user)
        |> redirect(to: SlackCoder.Router.Helpers.user_path(conn, :edit, db_user.id))
    end
  end

  defp authorize_url!, do: SlackCoder.OAuth.Github.authorize_url!

  defp update_user(user, db_user) do
    User.changeset(db_user || %User{}, user) |> Repo.insert_or_update!
  end

  defp find_or_create_user(raw_user) do
    %{github: github} = simplified_user = %{name: raw_user["name"], github: raw_user["login"], slack: raw_user["login"], avatar_url: raw_user["avatar_url"], html_url: raw_user["html_url"], config: %{}}
    db_user = from(u in User, where: u.github == ^github) |> Repo.one

    user = simplified_user |> update_user(db_user)
    SlackCoder.Users.Supervisor.start_user(user)
    if db_user, do: {:ok, user}, else: {:new, user}
  end

  defp after_login(conn, user) do
    conn
    |> put_flash(:info, "Successfully authenticated.")
    |> put_session(:current_user, user)
  end

end
