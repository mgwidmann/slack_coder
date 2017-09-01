defmodule SlackCoder.Features.Case do
  use ExUnit.CaseTemplate

  using do
    quote do
      use ExUnit.Case, async: true
      import Wallaby.Query
      use Wallaby.DSL

      # The default endpoint for testing
      @endpoint SlackCoder.Endpoint

      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      alias SlackCoder.Repo
      import Ecto.Schema
      import Ecto.Query, only: [from: 2]

      import SlackCoder.Router.Helpers

      setup_all do
        {:ok, _} = Application.ensure_all_started(:wallaby)
        Application.put_env(:wallaby, :base_url, SlackCoder.Endpoint.url)
      end

      setup tags do
        unless tags[:async] do
          Ecto.Adapters.SQL.Sandbox.mode(SlackCoder.Repo, {:shared, self()})
        end
        metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(SlackCoder.Repo, self())
        {:ok, session} = Wallaby.start_session(metadata: metadata)
        {:ok, %{session: session}}
      end
    end
  end
end
