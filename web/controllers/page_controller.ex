defmodule SlackCoder.PageController do
  use SlackCoder.Web, :controller

  def index(conn, params) do
    conn = assign conn, :prs, SlackCoder.Github.Watchers.Supervisor.pull_requests
    conn = assign conn, :user, params["user"]
    render conn, "index.html"
  end

  def synchronize(conn, %{"owner" => owner, "repo" => repo, "pr" => pr}) do
    SlackCoder.Github.synchronize_pull_request(owner, repo, pr)
    conn
    |> send_resp(:ok, "")
  end
end
