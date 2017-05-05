defmodule SlackCoder.Slack do
  use Slack
  import StubAlias
  import SlackCoder.Slack.Helper
  alias SlackCoder.Slack.Routing
  stub_alias SlackCoder.Users.Supervisor, as: Users
  stub_alias SlackCoder.Users.User
  alias SlackCoder.Models.Message
  alias SlackCoder.Repo
  require Logger
  @online_message """
  :slack: *Slack* :computer: *Coder* online!
  Reporting on any PRs since last online...
  """

  @doc """
  Sends the message to `user` to be processed and delivered.
  Two types accepted:
      send_to(:user, %SlackCoder.Github.Notification{})
      send_to(:user, "message")
  The first delivers the message to `user` process where based upon
  its logic and the `user`'s configuration it will either be delivered or
  discarded. The second is meant to be used only by the User processes, so
  that they may deliver messages to `:slack` through the RTM service.
  """
  def send_to(user, message)
  def send_to(user, notification = %SlackCoder.Github.Notification{}) when is_binary(user) do
    String.to_atom(user) |> send_to(notification)
  end

  def send_to(user, notification = %SlackCoder.Github.Notification{}) do
    user_pid = Users.user(user)
    if user_pid do
      User.notification user_pid, notification
    else
      Logger.error "Attempt to deliver message to #{inspect user}, but pid cannot be found. Notification: #{inspect notification}"
    end
  end

  def send_to(user, message) when is_binary(user) and is_binary(message) do
    String.to_atom(user) |> send_to(message)
  end

  def send_to(user, message) when is_binary(message) do
    send :slack, {user, message <> unquote(if Mix.env == :dev, do: "\n*DEV MESSAGE*", else: "")}
  end

  @doc """
  Retrieves the current slack data. Useful for inspecting the running process.
  """
  def slack() do
    send :slack, {:slack, self()}
    receive do
      data -> data
    end
  end

  @doc false
  def handle_info({:slack, pid}, slack, state) when is_pid(pid) do
    send pid, slack
    {:ok, state}
  end

  def handle_info({user, message}, slack, state) do
    {:ok, slack
          |> user(if(Mix.env == :dev, do: Application.get_env(:slack_coder, :caretaker), else: user))
          |> send_message_to_slack_user(user, message, slack)
          |> case do
              :ok -> state
              {:update, user} -> Map.merge(state, %{users: [user | Map.get(state, :users, [])]})
            end
          }
  end
  def handle_info(message, _slack, state) do
    Logger.warn "Got unhandled message: #{inspect message}"
    {:ok, state}
  end

  defp send_message_to_slack_user(nil, user, _message, slack) do
    caretaker = user(slack, Application.get_env(:slack_coder, :caretaker))
    send_message("I can't find a user named @#{user}, can you tell me what their slack name is?", caretaker.id, slack)
    {:update, user}
  end
  defp send_message_to_slack_user(slack_user, user, message, slack) do
    Task.Supervisor.start_child SlackCoder.TaskSupervisor, __MODULE__, :record_message, [slack_user[:name], user, message]

    message = message_for(slack_user, message)
    slack_user = Routing.route_message(slack, slack_user)
    if slack_user do
      message
      |> String.strip
      |> send_message(slack_user.id, slack)
    else
      Logger.error "Unable to send message to #{inspect user}! Slack data: #{inspect slack_user}"
    end
    :ok
  end

  @doc false
  def record_message(name, user, message) do
    Logger.info "Sending message (#{name}): #{message}"
    %Message{}
    |> Message.changeset(%{slack: to_string(user), user: name, message: message |> String.strip})
    |> Repo.insert!
  end

  @doc false
  def handle_close(reason, slack, _state) do
    Logger.error inspect(reason)
    caretaker = user(slack, Application.get_env(:slack_coder, :caretaker))
    caretaker_im = Routing.route_message(slack, caretaker)
    if caretaker_im do
      send_message("Crashing: #{inspect reason}", caretaker_im.id, slack)
    end
    {:error, reason}
  end

  @doc false
  def handle_connect(slack, _state) do
    try do
      Process.register(self(), :slack)
      channel = Routing.channel(slack)
      if channel, do: send_message(@online_message, channel.id, slack)
    rescue
      e ->
        Logger.error "Unable to connect to slack!\n#{inspect e}"
    end
    {:ok, %{}}
  end

  @doc false
  def handle_message(%{text: message, type: "message", user: user_id, channel: channel} = payload, slack, state) do
    caretaker = user(slack, Application.get_env(:slack_coder, :caretaker))
    new_state = resolve_user_update(state, message)
    unless user_id == caretaker.id || state != new_state do
      user_help(user_id, channel, message, payload, slack)
    end
    {:ok, state || %{}}
  end
  def handle_message(_message, _slack, state) do
    {:ok, state}
  end

  defp resolve_user_update(%{users: [github | remaining]} = state, slack) do
    user_pid = github |> Users.user()
    if user_pid do
      User.update(user_pid, %{slack: slack})
    end
    Map.put(state, :users, remaining)
  end
  defp resolve_user_update(%{users: []} = state, _message), do: state
  defp resolve_user_update(state, _message), do: state

  defp user_help(user_id, channel, message, payload, slack) do
    if should_respond_to_message?(user_id, channel, slack) && payload[:subtype] == nil do
      slack_name = slack[:users][user_id][:name]
      user_pid = Users.user(slack_name)
      if user_pid do
        User.help(user_pid, message)
      else
        send_to slack_name, """
        Sorry, but I can't chat until you've registered!

        Please register at http://slack-coder.herokuapp.com
        """
        Logger.warn "User #{inspect slack_name || user_id} sent us a message but it was ignored because the user_pid could not be found."
      end
    end
  end

  defp should_respond_to_message?(user_id, channel, slack) do
    # As long as its not a message from me and it was sent via a DM
    slack[:me][:id] != user_id && slack[:ims][channel]
  end

end
