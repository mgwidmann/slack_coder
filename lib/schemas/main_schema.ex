defmodule SlackCoder.Schemas.MainSchema do
  @moduledoc """
  """
  use Absinthe.Schema
  alias SlackCoder.{Repo, Models.User}
  import_types SlackCoder.Schemas.PR

  @desc "Only used for querying, never returned."
  enum :pull_request_type do
    value :mine, description: "Returns only `PullRequest`s that belong to the current user."
    value :monitors, description: "Returns only `PullRequest`s that belong to the current user's monitor list."
    value :other, description: "Returns `PullRequest`s that are not in the MINE or MONITORS category, based upon the current user."
    value :all, description: "Returns all active `PullRequest`s that are currently being tracked."
    value :inactive, description: "Returns all inactive `PullRequest`s that were previously tracked."
  end

  query do
    @desc "Fetch a group of PRs"
    field :pull_requests, type: :pull_request do
      @desc "The type of `PullRequest`s you'd like to fetch."
      arg :type, :pull_request_type

      resolve fn
        _, %{type: :mine}, _ ->
          {:ok, []}
        _, %{type: :monitors}, _ ->
          {:ok, []}
        _, %{type: :other}, _ ->
          {:ok, []}
        _, %{type: :all}, _ ->
          {:ok, []}
        _, %{type: :inactive}, _ ->
          {:ok, []}
      end
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
    field :users, type: list_of(:user) do
      resolve fn _, _, _ ->
        {:ok, Repo.all(User)}
      end
    end
  end

end
