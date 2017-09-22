defmodule SlackCoder.Web.RandomFailureController do
  use SlackCoder.Web, :controller

  def log(conn, %{"id" => id}) do
    failure_log = Repo.get!(FailureLog, id)
    conn
    |> text(failure_log.log)
  end
end
