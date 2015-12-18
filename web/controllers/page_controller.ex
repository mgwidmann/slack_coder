defmodule SlackCoder.PageController do
  use SlackCoder.Web, :controller

  def index(conn, params) do
    conn = assign conn, :prs, SlackCoder.Github.Supervisor.pull_requests
    conn = assign conn, :user, params["user"]
    render conn, "index.html"
  end
end
