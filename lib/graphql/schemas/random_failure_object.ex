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

  enum :system_type do
    value :travis, description: "Job was run on https://travis-ci.com/"
    value :circle_ci, description: "Job was run on https://circleci.com/"
    value :semaphore, description: "Job was run on https://semaphoreci.com/"
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
    @desc "The description of the test."
    field :description, :string
    @desc "The system used to run the test."
    field :type, :failure_type
    @desc "Which CI system the job was run on."
    field :system, :system_type
    @desc "Command to run to replicate this failure."
    field :run_command, :string, resolve: as(&RandomFailureResolver.run_command/1)
    @desc "The log information for this failed job."
    field :log, :log, resolve: assoc(:failure_log)

    timestamps()
  end

  object :log do
    @desc "The primary identifier for each failure."
    field :id, :id

    @desc "The Pull Request which this random failure occurred."
    field :pull_request, :pull_request, resolve: assoc(:pr)
    @desc "The external system ID which the log was retrieved from."
    field :external_id
    @desc "The URL to the captured log file within the slack bot."
    field :log_url, :string, resolve: as(&RandomFailureResolver.log_url/1)
    @desc "The parsed cucumber test portion of the failure log."
    field :cucumber_failure
    @desc "The parsed rspec test portion of the failure log."
    field :rspec_failure
  end
end
