defmodule SlackCoder.ChannelCase do
  @moduledoc """
  This module defines the test case to be used by
  channel tests.

  Such tests rely on `Phoenix.ChannelTest` and also
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

      # Import conveniences for testing with channels
      use Phoenix.ChannelTest

      alias SlackCoder.Repo
      import Ecto.Schema
      import Ecto.Query, only: [from: 2]
    end
  end

end
