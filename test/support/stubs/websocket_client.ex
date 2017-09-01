defmodule SlackCoder.Stubs.WebsocketClient do
  def start_link(_url, _module, _state, _options) do
    {:ok, spawn_link(fn -> Process.sleep(:infinity) end)}
  end
end
