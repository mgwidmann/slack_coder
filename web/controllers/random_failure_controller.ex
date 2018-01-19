defmodule SlackCoder.Web.RandomFailureController do
  use SlackCoder.Web, :controller

  alias SlackCoder.BuildSystem.LogParser

  def log(conn, %{"id" => id}) do
    failure_log = Repo.get!(FailureLog, id)
    conn
    |> text(failure_log.log)
  end

  def failed_tests(conn, %{"id" => id}) do
    failure_log = Repo.get!(FailureLog, id)
    failure_log.log
    |> LogParser.parse
  end
end
