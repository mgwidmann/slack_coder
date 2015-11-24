defmodule SlackCoder.Slack do
  use Slack
  import SlackCoder.Slack.Helper
  alias SlackCoder.Config
  require Logger
  @online_message """
  :slack: *Slack* :computer: *Coder* online!
  Reporting on any PRs since last online...
  """

  def send_to(user, message) when is_binary(user) do
    String.to_atom(user) |> send_to(message)
  end

  def send_to(user, message) do
    send :slack, {user, String.strip(message)}
  end

  def handle_info({user, message}, slack, state) do
    user = user(slack, user)
    message = message_for(user, message)
    Logger.info "Sending message (#{user.name}): #{message}"
    send_message(message, Config.route_message(slack, user).id, slack)
    {:ok, state}
  end
  def handle_info(message, _slack, state) do
    Logger.warn "Got unhandled message: #{inspect message}"
    {:ok, state}
  end

  def handle_close(reason, slack, _state) do
    Logger.error inspect(reason)
    caretaker = user(slack, Application.get_env(:slack_coder, :caretaker))
    send_message("Crashing: #{inspect reason}", Config.route_message(slack, caretaker).id, slack)
    {:error, reason}
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

end
