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
    value :hidden, description: "The PR has been hidden from view the main dashboard view."
    value :merged, description: "The PR has been merged."
  end

  @desc "Only used for querying, never returned"
  enum :random_failure_sort_field do
    value :count, description: "Sort by the highest occurance"
    value :recent, description: "Sort by the most recent failure"
    value :priority, description: """
    Sorts by the failures that are highest priority. Priority is defined as the
    length of time between the first occurance and the most recent (minutes between `updatedAt` - `insertedAt`)
    to the power of `count`. This means the `count` value has a significant impact on priority
    score, however since the open timeframe serves as a base it will make a big impact
    on those with similar `count` values. To see the priority score calculated, select the field `priorityScore`.
    """
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
        _, %{type: :monitors} = args, %{context: %{current_user: current_user}} ->
          SlackCoder.GraphQL.Resolvers.PRResolver.list(current_user, :monitors, args[:status] || :open)
        _, _, _ ->
          {:error, %{message: "Must be signed in."}}
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
      arg :current, :boolean

      resolve fn
        _, %{id: id}, _ ->
          {:ok, Repo.get(User, id)}
        _, %{current: true}, %{context: %{current_user: current_user}} ->
          {:ok, current_user}
      end
    end

    @desc "Fetching users of the system."
    field :users, type: :pagination do
      @desc "The page number"
      arg :page, :integer
      @desc "The number of items in a page, maximum 100"
      arg :page_size, :integer
      @desc "Searches for a user."
      arg :search, :string
      resolve &SlackCoder.GraphQL.Resolvers.UserResolver.list/3
    end

    @desc "List of random failures"
    field :failures, type: :pagination do
      @desc "The page number"
      arg :page, :integer
      @desc "The number of items in a page, maximum 100"
      arg :page_size, :integer
      @desc "Sort by"
      arg :sort, :random_failure_sort_field
      @desc "Sort direction"
      arg :dir, :direction
      @desc "The owner of the repoistory"
      arg :owner, :string
      @desc "The repository name"
      arg :repository
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

    @desc "Refreshes the PR from github"
    field :synchronize, type: :pull_request do
      arg :owner, non_null(:string)
      arg :repository, non_null(:string)
      arg :number, non_null(:integer)

      resolve &SlackCoder.GraphQL.Resolvers.PRResolver.synchronize/3
    end

    @desc "Hides or unhides a pull request from the main dashboard view."
    field :toggle_hide_pull_request, type: :pull_request do
      arg :id, non_null(:id)

      resolve &SlackCoder.GraphQL.Resolvers.PRResolver.toggle_hide_pull_request/3
    end

    field :resolve_failure, type: :failure do
      arg :id, non_null(:id)

      resolve &SlackCoder.GraphQL.Resolvers.RandomFailureResolver.resolve/3
    end
  end

  subscription do
    field :pull_request, :pull_request do
      arg :id, non_null(:id)

      config fn %{id: id}, _ ->
        {:ok, topic: id}
      end
    end

    field :new_pull_request, :pull_request do
      config fn _, _ ->
        {:ok, topic: "new_pull_request"}
      end
    end
  end
end
