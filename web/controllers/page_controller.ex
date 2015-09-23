defmodule SlackCoder.PageController do
  use SlackCoder.Web, :controller

  def index(conn, _params) do
    conn = assign conn, :prs, SlackCoder.Github.Supervisor.pull_requests
    render conn, "index.html"
  end
end
