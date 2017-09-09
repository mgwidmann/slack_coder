defmodule SlackCoder.GraphQL.Schemas.PR do
  @moduledoc """
  """
  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: SlackCoder.Repo
  import SlackCoder.GraphQL.Resolvers.DefaultResolvers


  @desc "A replica of the Github Pull Request data stripped down to what this project needs."
  object :pull_request do
    field :id, :id

    @desc "The owner of the repository, either the user or organization name."
    field :owner, :string
    @desc "The repository name of the pull request."
    field :repository, :string, resolve: as(:repo)
    @desc "The name of the branch of the pull request submitter."
    field :branch, :string
    @desc "If the branch of the pull request submitter is from a fork or not."
    field :fork, :boolean

    # Stale PR tracking
    @desc "The timestamp of the last comment on the `PullRequest`."
    field :latest_comment, :datetime
    @desc "The URL to the latest comment."
    field :latest_comment_url, :string
    @desc "The timestamp of when the `PullRequest` was opened."
    field :opened_at, :datetime
    @desc "The timestamp of when the `PullRequest` was closed (does not include merging)."
    field :closed_at, :datetime
    @desc "The timestamp of when the `PullRequest` was merged (does not include closing unless it was previously closed)."
    field :merged_at, :datetime
    @desc "The number of hours after the latest comment timestamp in which a stale notification will be sent. Nights and weekends automatically excluded."
    field :backoff, :integer

    # Used in view
    @desc "The title of the `PullRequest`."
    field :title, :string
    @desc "The Github Pull Request primary identifier."
    field :number, :integer
    @desc "The HTML interface URL of the `PullRequest`."
    field :html_url, :string
    @desc "If the `PullRequest` is in a mergable state (there are no conflicts, does not take into account build status)."
    field :mergeable, :boolean

    # # Build status info
    @desc "The latest git commit SHA."
    field :sha, :string
    @desc "The status of the build."
    field :build_status, :pull_request_build_status
    @desc "The status of the code analysis."
    field :analysis_status, :pull_request_analysis_status
    @desc "The HTML URL of the build."
    field :build_url, :string
    @desc "The HTML URL of the code analysis."
    field :analysis_url, :string

    @desc "The user who opened the `PullRequest`."
    field :user, :user
  end

  @desc "The status of a `PullRequest` build"
  enum :pull_request_build_status do
    value :failed, description: "The build did not succeed (tests failed)."
    value :error, description: "The build failed because of an error which prevented it from running to completion."
    value :conflict, description: "There is a merge conflict."
    value :pending, description: "The build is currently being processed."
    value :success, description: "The build successfully passed all tests."
  end

  @desc "The status of a `PullRequest` code analysis"
  enum :pull_request_analysis_status do
    value :failed, description: "The changes added code style issues."
    value :pending, description: "The code analysis is currently being processed."
    value :success, description: "The build successfully passed all analysis checks."
  end
end
