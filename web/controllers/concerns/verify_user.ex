defmodule SlackCoder.VerifyUser do
  import Plug.Conn
  alias SlackCoder.Models.User
  require Logger

  def init(opts), do: opts

  def call(conn, opts) do
    if admin?(conn, opts) || conn.assigns[:current_user] do
      conn
    else
      Logger.warn "Attempt to access unauthorized page! user: #{inspect conn.assigns[:current_user]}"
      conn
      |> put_resp_content_type("text/html")
      |> send_resp(404, Phoenix.HTML.safe_to_string(SlackCoder.ErrorView.render("404.html")))
      |> halt
    end
  end

  defp verify(%User{admin: true}, _params), do: true
  defp verify(_, _), do: false

  defp admin?(conn, opts) do
    opts[:admin] && verify(conn.assigns.current_user, conn.params)
  end
end
