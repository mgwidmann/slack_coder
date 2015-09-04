defmodule SlackCoder.Slack do
  use Slack
  import SlackCoder.Slack.Helper
  require Logger

  def send_to(user, message) do
    send :slack, {user, message}
  end

  def handle_info({user, message}, slack) do
    user = user(slack, user)
    group_name = Application.get_env(:slack_coder, :group)
    channel_name = Application.get_env(:slack_coder, :channel)
    group_or_channel = cond do
                         channel = channel(slack, channel_name) -> channel
                         group = group(slack, group_name) -> group
                         true -> raise "Could not find either channel #{channel_name} or group #{group_name}"
                       end
    send_message("<@#{user.id}> #{message}", group_or_channel.id, slack)
    {:ok, slack}
  end

  def handle_connect(_slack, state) do
    Process.register(self, :slack)
    {:ok, state}
  end

  def handle_message(_message, _slack, state) do
    {:ok, state}
  end

  def websocket_info(msg, _connection, state) do
    {:ok, slack} = SlackCoder.Slack.handle_info(msg, state.slack)
    {:ok, %{ state | slack: slack}}
  end

end
