defmodule Fixtures do
  defmodule PRs do
    @title_changed File.read!("test/support/fixtures/pull_request/title_changed.json") |> Poison.decode!()
    def title_changed(), do: @title_changed
  end
end
