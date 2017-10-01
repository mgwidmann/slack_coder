defmodule SlackCoder.GraphQL.Schemas.User do
  @moduledoc """
  """
  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: SlackCoder.Repo
  import SlackCoder.GraphQL.Resolvers.DefaultResolvers

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
    field :monitors, list_of(:user), resolve: &SlackCoder.GraphQL.Resolvers.UserResolver.monitors/3
    @desc "This user has opted to not receive any notifications from the slack bot."
    field :muted, :boolean

    field :config, :user_config

    @desc "If this user is an administrator of SlackCoder"
    field :admin, :boolean
  end

  object :user_config do
    @desc "Notifies the user when their own pull requests open"
    field :open_self, :boolean
    @desc "Notifies the user when their own pull requests close"
    field :close_self, :boolean
    @desc "Notifies the user when their own pull requests fail"
    field :fail_self, :boolean
    @desc "Notifies the user when their own pull requests pass"
    field :pass_self, :boolean
    @desc "Notifies the user when their own pull requests merge"
    field :merge_self, :boolean
    @desc "Notifies the user when their own pull requests conflict"
    field :conflict_self, :boolean
    @desc "Notifies the user when their monitors' pull requests open"
    field :open_monitors, :boolean
    @desc "Notifies the user when their monitors' pull requests close"
    field :close_monitors, :boolean
    @desc "Notifies the user when their monitors' pull requests fail"
    field :fail_monitors, :boolean
    @desc "Notifies the user when their monitors' pull requests pass"
    field :pass_monitors, :boolean
    @desc "Notifies the user when their monitors' pull requests merge"
    field :merge_monitors, :boolean
    @desc "Notifies the user when their monitors' pull requests conflict"
    field :conflict_monitors, :boolean
  end
end
