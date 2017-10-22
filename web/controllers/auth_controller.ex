defmodule SlackCoder.AuthController do
  use SlackCoder.Web, :controller

  alias SlackCoder.Services.UserService

  @doc """
  This action is reached via `/auth/:provider` and redirects to the OAuth2 provider
  based on the chosen strategy.
  """
  def index(conn, %{"provider" => "github"}) do
    redirect conn, external: authorize_url!()
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> SlackCoder.Guardian.Plug.sign_out()
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
      %Ueberauth.Auth.Extra{raw_info: %{token: %{access_token: _token}, user: raw_user}}}}} = conn, _params) do
    case raw_user |> UserService.find_or_create_user() do
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

  defp after_login(conn, user) do
    conn = conn
           |> SlackCoder.Guardian.Plug.sign_in(user, %{admin: user.admin})
           |> SlackCoder.Guardian.Plug.remember_me(user, %{admin: user.admin}, [])
           |> put_flash(:info, "Successfully authenticated.")

    SlackCoder.Slack.send_to(user.slack, "Signed in successfully!")

    conn
  end

  def token_refresh(conn, %{"token" => token}) do
    {:ok, {_old_token, _old_claims}, {new_token, _new_claims}} = SlackCoder.Guardian.exchange token, "refresh", "access"
    conn
    |> json(%{token: new_token})
  end

end
