defmodule SlackCoder.Users.User do
  use GenServer
  require Logger
  import SlackCoder.Users.Help
  alias SlackCoder.Repo
  alias SlackCoder.Models.User
  alias SlackCoder.Slack
  alias SlackCoder.Github.Notification

  # Server API

  def start_link(user) do
    GenServer.start_link __MODULE__, user
  end

  def init(user) do
    {:ok, user}
  end

  for type <- SlackCoder.Users.Help.message_types() do
    def handle_cast(%Notification{type: unquote(type), called_out?: called_out, message: message, message_for: user_for}, user) do
      if configured_to_send_message(unquote(type), called_out, user_for, user) do
        Slack.send_to(user.slack, message)
      else
        Logger.debug "Not configured to send #{unquote(type)} to #{user.slack}#{if(user.muted, do: " **MUTED**", else: "")}"
      end
      {:noreply, user}
    end
  end
  # Don't send unknown messages
  def handle_cast(notification = %Notification{}, user) do
    Logger.warn "User #{user.name}(#{user.slack}) received unhandled message: #{inspect notification}"
    {:noreply, user}
  end

  def handle_cast({:help, message}, user) do
    {new_config, reply} = handle_message(message |> String.downcase |> String.split(" "), user.config |> Map.from_struct |> Map.delete(:__meta__))
    {:ok, user} = User.changeset(user, %{config: new_config}) |> Repo.update
    if reply do
      Slack.send_to(user.slack, reply)
    end
    {:noreply, user}
  end
  def handle_cast({:update, new_user}, _user) do
    {:noreply, new_user}
  end

  def handle_call(:get, _from, user) do
    {:reply, user, user}
  end

  def configured_to_send_message(_type, _called_out, _user_for, %User{muted: true}), do: false
  def configured_to_send_message(type, called_out, user_for, user) do
    config_self = if (config_self = Map.get(user.config, :"#{type}_self")) != nil, do: config_self, else: true
    config_monitors = if (config_monitors = Map.get(user.config, :"#{type}_monitors")) != nil, do: config_monitors, else: true
    config_callouts = if (config_callouts = Map.get(user.config, :"#{type}_callouts")) != nil, do: config_callouts, else: true

    (user.slack == user_for && config_callouts && called_out) ||
      (user.slack == user_for && config_self && !called_out) ||
      (user.slack != user_for && config_monitors && !called_out)
  end

  # Client API

  def notification(user_pid, {type, called_out, user, message}) do
    GenServer.cast user_pid, {type, called_out, user, message}
  end

  def help(user_pid, message) do
    GenServer.cast user_pid, {:help, message}
  end

  def get(nil), do: nil
  def get(user_pid) when is_pid(user_pid) do
    GenServer.call user_pid, :get
  end

  def update(user_pid, user) when is_pid(user_pid) do
    GenServer.cast user_pid, {:update, user}
  end

end
