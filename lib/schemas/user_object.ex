defmodule SlackCoder.Schemas.User do
  @moduledoc """
  """
  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: SlackCoder.Repo
  import SlackCoder.Resolvers.DefaultResolvers
  # alias SlackCoder.Github.Notification, as: N

  import_types SlackCoder.Schemas.Scalars

  object :user do
    @desc "The primary identifier for each user."
    field :id, :id

    @desc "The user's Slack nickname (username)."
    field :slack, :string
    @desc "The user's Github nickname (username)."
    field :github, :string
    @desc "The user's Github avatar image URL."
    field :avatar_url, :string
    @desc "The user's Github HTML URL."
    field :html_url, :string
    @desc "The user's real name."
    field :name, :string
    @desc "The github names of whom this user wants to monitor."
    field :github_monitors, list_of(:string), resolve: as(:monitors)
    @desc "This user has opted to not receive any notifications from the slack bot."
    field :muted, :boolean

    @desc "If this user is an administrator of SlackCoder"
    field :admin, :boolean
  end
end
