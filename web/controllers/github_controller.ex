defmodule SlackCoder.GithubController do
  use SlackCoder.Web, :controller

  def event(conn, params) do
    IO.puts "GOT EVENT FROM GITHUB!"
    IO.inspect params
    text conn, "GOT IT!"
  end

end
