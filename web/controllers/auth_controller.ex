defmodule SlackCoder.AuthController do
  use SlackCoder.Web, :controller

  alias SlackCoder.Services.UserService

  @doc """
  This action is reached via `/auth/:provider` and redirects to the OAuth2 provider
  based on the chosen strategy.
  """
  def request(conn, %{"provider" => "github"}) do
    redirect conn, external: authorize_url!()
  end

  # if Mix.env == :test do
    def request(conn, %{"provider" => "identity"}) do
      Logger.debug "Redirecting to identity callback"
      conn
      |> redirect(to: auth_path(conn, :callback, "identity"))
    end
  # end

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
      %Ueberauth.Auth.Extra{raw_info: raw_info}}}} = conn, _params) do
    token = token(raw_info)
    raw_user = user(raw_info)
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
    SlackCoder.Slack.send_to(user.slack, "Signed in successfully!")
    conn
    |> put_flash(:info, "Successfully authenticated.")
    |> put_session(:current_user, user)
  end

  defp token(%{token: %{access_token: token}}), do: token
  defp token(_), do: nil

  defp user(%{user: raw_user}), do: raw_user
  defp user(_), do: %{}

end
