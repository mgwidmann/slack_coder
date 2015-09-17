defmodule SlackCoder.Config do
  import SlackCoder.Slack.Helper

  def channel(slack) do
    group_name = Application.get_env(:slack_coder, :group)
    channel_name = Application.get_env(:slack_coder, :channel)
    cond do
      channel = channel(slack, channel_name) -> channel
      group = group(slack, group_name) -> group
      true -> raise "Could not find either channel #{channel_name} or group #{group_name}"
    end
  end

end
