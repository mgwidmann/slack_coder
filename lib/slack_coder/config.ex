defmodule SlackCoder.Config do
  import SlackCoder.Slack.Helper
  require Logger

  def channel(slack) do
    group_name = Application.get_env(:slack_coder, :group)
    channel_name = Application.get_env(:slack_coder, :channel)
    cond do
      channel = channel(slack, channel_name) -> channel
      group = group(slack, group_name) -> group
      true ->
        message = "Could not find either channel #{inspect channel_name} or group #{inspect group_name}"
        Logger.error message
        raise message
    end
  end

end
