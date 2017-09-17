defmodule SlackCoder.Guardian do
  use Guardian, otp_app: :slack_coder
  alias SlackCoder.Models.User
  alias SlackCoder.Repo

  def subject_for_token(%User{id: id}, _claims) do
    {:ok, to_string(id)}
  end
  def subject_for_token(_, _) do
    {:error, :unauthorized}
  end

  def resource_from_claims(claims) do
    IO.puts "Getting user for #{inspect claims}"
    {:ok, Repo.get!(User, claims["sub"])}
  end

  defmodule CurrentUser do
    import Plug.Conn
    @moduledoc """
    Fetch the current user from the session and add it to `conn.assigns`. This
    will allow you to have access to the current user in your views with
    `@current_user`.
    """
    def init(_), do: nil
    def call(conn, _) do
      current_user = SlackCoder.Guardian.Plug.current_resource(conn)
      conn
      |> assign(:current_user, current_user)
      |> put_private(:absinthe, %{context: %{current_user: current_user}})
    end
  end

  defmodule Pipeline do
    use Guardian.Plug.Pipeline, otp_app: :slack_coder,
                                module: SlackCoder.Guardian,
                                error_handler: SlackCoder.Guardian.AuthErrorHandler

    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource, allow_blank: true
    plug SlackCoder.Guardian.CurrentUser
  end

  defmodule RestrictedPipeline do
    use Guardian.Plug.Pipeline, otp_app: :slack_coder,
                                module: SlackCoder.Guardian,
                                error_handler: SlackCoder.Guardian.AuthErrorHandler

    plug Guardian.Plug.EnsureAuthenticated
    plug Guardian.Plug.LoadResource
    plug SlackCoder.Guardian.CurrentUser
  end

  defmodule AdminPipeline do
    use Guardian.Plug.Pipeline, otp_app: :slack_coder,
                                module: SlackCoder.Guardian,
                                error_handler: SlackCoder.Guardian.AuthErrorHandler

    plug Guardian.Plug.VerifySession, claims: %{admin: true}
    plug Guardian.Plug.LoadResource
    plug SlackCoder.Guardian.CurrentUser
  end

  defmodule AuthErrorHandler do
    import Plug.Conn

    def auth_error(conn, {type, _reason}, _opts) do
      body = Poison.encode!(%{message: to_string(type)})
      send_resp(conn, 401, body)
    end
  end
end
