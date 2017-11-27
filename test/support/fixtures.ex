defmodule Fixtures do
  defmodule PRs do
    for file <- ~w(title_changed synchronize status_pending status_success status_failed)a do
      Module.put_attribute(__MODULE__, file, File.read!("test/support/fixtures/pull_request/#{file}.json") |> Poison.decode!())
      def unquote(file)(), do: unquote(Macro.escape Module.get_attribute(__MODULE__, file))
    end
  end

  defmodule Builds do
    for file <- ~w(failed_rspec_and_cucumber failed_jest failed_minitest)a do
      Module.put_attribute(__MODULE__, file, File.read!("test/support/fixtures/build_system/#{file}.txt"))
      def unquote(file)(), do: unquote(Macro.escape Module.get_attribute(__MODULE__, file))
    end
  end
end
