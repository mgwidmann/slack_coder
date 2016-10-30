defmodule SlackCoder.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  imports other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      use ExUnit.Case, async: true

      # The default endpoint for testing
      @endpoint SlackCoder.Endpoint

      # Import conveniences for testing with connections
      use Phoenix.ConnTest

      alias SlackCoder.Repo
      import Ecto.Model
      import Ecto.Query, only: [from: 2]

      import SlackCoder.Router.Helpers

      setup do
        :ok = Ecto.Adapters.SQL.Sandbox.checkout(SlackCoder.Repo)
      end
    end
  end
end
