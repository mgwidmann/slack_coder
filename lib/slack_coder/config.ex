defmodule SlackCoder.Config do
  import SlackCoder.Slack.Helper
  require Logger

  def route_message(slack, user) do
    channel(slack) || im(slack, user.id)
  end

  def channel(slack) do
    group_name = Application.get_env(:slack_coder, :group)
    channel_name = Application.get_env(:slack_coder, :channel)
    cond do
      channel = channel(slack, channel_name) -> channel
      group = group(slack, group_name) -> group
      true -> nil
    end
  end

  def slack_user(github_user) do
    Application.get_env(:slack_coder, :users, [])[github_user][:slack]
  end

end
