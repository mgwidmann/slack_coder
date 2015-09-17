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

  def handle_info({user, message}, slack) do
    user = user(slack, user)
    send_message("<@#{user.id}> #{message}", Config.channel(slack).id, slack)
    {:ok, slack}
  end

  def handle_connect(slack, state) do
    Process.register(self, :slack)
    send_message(@online_message, Config.channel(slack).id, slack)
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
