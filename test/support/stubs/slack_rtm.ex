defmodule SlackCoder.Stubs.SlackRtm do
  def start(_token) do
    {:ok, %{url: "http://www.example.com"}}
  end
end
