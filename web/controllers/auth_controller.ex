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
  def callback(conn, %{"provider" => "github", "code" => code}) do
    # Exchange an auth code for an access token
    token = get_token!(code)

    # Request the user's data with the access token
    user = get_user!(token)
    github = user.github
    db_user = from(u in User, where: u.github == ^github) |> Repo.one
    if db_user do
      {:ok, db_user} = User.changeset(db_user, user) |> Repo.update
    end
    # Store the user in the session under `:current_user` and redirect to /.
    # In most cases, we'd probably just store the user's ID that can be used
    # to fetch from the database. In this case, since this example app has no
    # database, I'm just storing the user map.
    #
    # If you need to make additional resource requests, you may want to store
    # the access token as well.
    conn = conn
          |> put_session(:access_token, token.access_token)
    if db_user do
      SlackCoder.Users.Supervisor.start_user(db_user)
      conn
      |> put_session(:current_user, db_user)
      |> redirect(to: "/")
    else
      conn
      |> put_session(:current_user, struct(User, user))
      |> redirect(to: user_path(conn, :new))
    end
  end

  defp authorize_url!, do: SlackCoder.OAuth.Github.authorize_url!

  defp get_token!(code),   do: SlackCoder.OAuth.Github.get_token!(code: code)

  defp get_user!(token) do
    # Fetch github user from github using token
    {:ok, %{body: %{"name" => name, "login" => login, "avatar_url" => avatar, "html_url" => html}}} = OAuth2.AccessToken.get(token, "/user")
    %{name: name, github: login, avatar_url: avatar, html_url: html}
  end

end
