defmodule SlackCoder.Config do
  import SlackCoder.Slack.Helper
  require Logger

  def route_message(slack, user) do
    channel(slack) || im(slack, user.id)
  end

  def channel(slack) do
    group_name = Application.get_env(:slack_coder, :notifications)[:group]
    channel_name = Application.get_env(:slack_coder, :notifications)[:channel]
    cond do
      channel = channel(slack, channel_name) -> channel
      group = group(slack, group_name) -> group
      true -> nil
    end
  end

  def slack_user(github_user) when is_binary(github_user) do
    github_user
    |> String.to_atom
    |> slack_user
  end

  def slack_user(github_user) do
    Application.get_env(:slack_coder, :users, [])[github_user][:slack]
  end

end
