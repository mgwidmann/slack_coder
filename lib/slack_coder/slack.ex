defmodule SlackCoder.Slack do
  use Slack
  import SlackCoder.Slack.Helper
  alias SlackCoder.Config
  require Logger
  @online_message """
  :slack: *Slack* :computer: *Coder* online!
  Reporting on any PRs since last online...
  """

  def send_to(user, message) do
    send :slack, {user, message}
  end

  def handle_info({user, message}, slack, state) do
    user = user(slack, user)
    send_message(message_for(user, message), Config.route_message(slack, user).id, slack)
    {:ok, slack}
  end

  def handle_connect(slack, state) do
    Process.register(self, :slack)
    channel = Config.channel(slack)
    if channel, do: send_message(@online_message, channel.id, slack)
    {:ok, state}
  end

  def handle_message(_message, _slack, state) do
    {:ok, state}
  end

  def websocket_info(message, _connection, %{slack: slack, state: state}) do
    handle_info(message, slack, state)
    {:ok, %{slack: slack, state: state}}
  end

end
