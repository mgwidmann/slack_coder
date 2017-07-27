defmodule SlackCoder.Web.FallbackController do
  use Phoenix.Controller

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> render(SlackCoder.ErrorView, :"404")
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> render(SlackCoder.ErrorView, :"401")
  end

  def call(conn, _) do
    conn
    |> put_status(:internal_server_error)
    |> render(SlackCoder.ErrorView, :"500")
  end

end
