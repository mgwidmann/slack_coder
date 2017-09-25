defmodule SlackCoder.GraphQL.Schemas.MainSchema do
  @moduledoc """
  """
  use Absinthe.Schema
  alias SlackCoder.{Repo, Models.User}

  import_types SlackCoder.GraphQL.Schemas.Scalars
  import_types SlackCoder.GraphQL.Schemas.User
  import_types SlackCoder.GraphQL.Schemas.PR
  import_types SlackCoder.GraphQL.Schemas.RandomFailure
  import_types SlackCoder.GraphQL.InputObjects.User
  import_types SlackCoder.GraphQL.Schemas.Pagination

  @desc "Only used for querying, never returned."
  enum :pull_request_type do
    value :mine, description: "Returns only `PullRequest`s that belong to the current user."
    value :monitors, description: "Returns only `PullRequest`s that belong to the current user's monitor list."
    # value :other, description: "Returns `PullRequest`s that are not in the MINE or MONITORS category, based upon the current user."
    # value :all, description: "Returns all active `PullRequest`s that are currently being tracked."
    # value :inactive, description: "Returns all inactive `PullRequest`s that were previously tracked."
  end

  enum :pull_request_status do
    value :open, description: "The PR is currently open."
    value :merged, description: "The PR has been merged."
  end

  @desc "Only used for querying, never returned"
  enum :random_failure_sort_field do
    value :count, description: ""
    value :recent, description: ""
  end

  @desc "Direction used for sorting. Query only, never returned."
  enum :direction do
    value :asc, description: "Values sorted in ascending order."
    value :desc, description: "Values sorted in descending order."
  end

  query do
    @desc "Fetch a group of PRs"
    field :pull_requests, type: list_of(:pull_request) do
      @desc "The type of `PullRequest`s you'd like to fetch."
      arg :type, non_null(:pull_request_type)
      arg :status, :pull_request_status

      resolve fn
        _, %{type: :mine} = args, %{context: %{current_user: current_user}} ->
          SlackCoder.GraphQL.Resolvers.PRResolver.list(current_user, :mine, args[:status] || :open)
        _, %{type: :monitors}, %{context: %{current_user: _current_user}} ->
          {:ok, []}
      end
    end

    @desc "Fetch a single PR"
    field :pull_request, type: :pull_request do
      @desc "The primary key"
      arg :id, :id
      arg :owner, :string
      arg :repository, :string
      arg :number, :integer

      resolve &SlackCoder.GraphQL.Resolvers.PRResolver.pull_request/3
    end

    @desc "Fetching an individual user of the system."
    field :user, type: :user do
      @desc "The primary identifier of the desired user."
      arg :id, :id

      resolve fn _, %{id: id}, _ ->
        {:ok, Repo.get(User, id)}
      end
    end

    @desc "Fetching users of the system."
    field :users, type: :pagination do
      @desc "The page number"
      arg :page, :integer
      @desc "The number of items in a page, maximum 100"
      arg :per_page, :integer
      resolve &SlackCoder.GraphQL.Resolvers.UserResolver.list/3
    end

    @desc "List of random failures"
    field :failures, type: :pagination do
      @desc "The page number"
      arg :page, :integer
      @desc "The number of items in a page, maximum 100"
      arg :per_page, :integer
      @desc "Sort by"
      arg :sort, :random_failure_sort_field
      @desc "Sort direction"
      arg :dir, :direction
      resolve &SlackCoder.GraphQL.Resolvers.RandomFailureResolver.list/3
    end
  end

  mutation do
    @desc "Changes information on a particular user."
    field :user_update, type: :user do
      arg :id, non_null(:id)
      arg :user, :user_input

      resolve &SlackCoder.GraphQL.Resolvers.UserResolver.update/3
    end
  end

end
