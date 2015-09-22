defmodule SlackCoder.PageController do
  use SlackCoder.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
