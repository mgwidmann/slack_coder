defmodule SlackCoder.GraphQL.Schemas.RandomFailure do
  @moduledoc """
  """
  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: SlackCoder.Repo
  import SlackCoder.GraphQL.Resolvers.DefaultResolvers
  alias SlackCoder.GraphQL.Resolvers.RandomFailureResolver

  enum :failure_type do
    value :rspec, description: "This failure occurred within an RSpec test."
    value :cucumber, description: "This failure occurred within a cucumber integration test."
  end

  object :failure do
    @desc "The primary identifier for each failure."
    field :id, :id

    @desc "The owner/user where the repository is located."
    field :owner, :string
    @desc "The repository where the failure happened."
    field :repo, :string
    @desc "The first known PR in which the failure occurred."
    field :pr, :integer
    @desc "The first known SHA in which the failure occurred."
    field :sha, :string
    @desc "The test file in which the failure occurred."
    field :file, :string
    @desc "The line number in which the failure occurred."
    field :line, :integer
    @desc "The first seed in which the failure occurred."
    field :seed, :integer
    @desc "The number of times this failure has occurred."
    field :count, :integer
    @desc "The browser URL to the build"
    field :log_url, :string
    @desc "The system used to run the test."
    field :type, :failure_type
    @desc "Command to run to replicate this failure."
    field :run_command, :string, resolve: as(&RandomFailureResolver.run_command/1)

    timestamps()
  end
end
