defmodule SlackCoder.Slack do
  use Slack
  import SlackCoder.Slack.Helper
  alias SlackCoder.Config
  alias SlackCoder.Users.Supervisor, as: Users
  alias SlackCoder.Users.User
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

  def slack() do
    send :slack, {:slack, self()}
    receive do
      data -> data
    end
  end

  def handle_info({:slack, pid}, slack, state) when is_pid(pid) do
    send pid, slack
    {:ok, state}
  end
  def handle_info({user, message}, slack, state) do
    try do
      s_user = user(slack, user)
      message = message_for(s_user, message)
      slack_user = Config.route_message(slack, s_user)
      if slack_user do
        Logger.info "Sending message (#{s_user[:name]}): #{message}"
        send_message(message, slack_user.id, slack)
      else
        Logger.error "Unable to send message to #{inspect user}"
      end
    rescue
      e ->
        Logger.error "Error sending messge to: #{user}\n#{inspect e}"
    end
    {:ok, state}
  end
  def handle_info(message, _slack, state) do
    Logger.warn "Got unhandled message: #{inspect message}"
    {:ok, state}
  end

  def handle_close(reason, slack, _state) do
    Logger.error inspect(reason)
    caretaker = user(slack, Application.get_env(:slack_coder, :caretaker))
    caretaker_im = Config.route_message(slack, caretaker)
    if caretaker_im do
      send_message("Crashing: #{inspect reason}", caretaker_im.id, slack)
    end
    {:error, reason}
  end

  def handle_connect(slack, state) do
    try do
      Process.register(self, :slack)
      channel = Config.channel(slack)
      if channel, do: send_message(@online_message, channel.id, slack)
    rescue
      e ->
        Logger.error "Unable to connect to slack!\n#{inspect e}"
    end
    {:ok, state}
  end

  def handle_message(%{text: message, type: "message", user: user_id}, slack, state) do
    slack_name = slack[:users][user_id]["name"]
    if slack_name do
      User.help(Users.user(slack_name), message)
    end
    {:ok, state}
  end
  def handle_message(_message, _slack, state) do
    {:ok, state}
  end

end
