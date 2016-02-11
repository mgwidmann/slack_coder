defmodule SlackCoder.Users.User do
  use GenServer
  alias SlackCoder.Repo
  alias SlackCoder.Models.User
  alias SlackCoder.Slack
  import SlackCoder.Users.Help
  require Logger

  # Server API

  def start_link(user) do
    GenServer.start_link __MODULE__, user
  end

  def init(user) do
    {:ok, user}
  end

  for type <- SlackCoder.Users.Help.message_types() do
    def handle_cast({unquote(type), user_for, message}, user) do
      if configured_to_send_message(unquote(type), user_for, user) do
        Slack.send_to(user.slack, message)
      else
        Logger.debug "Not configured to send #{unquote(type)} to #{user.slack}"
      end
      {:noreply, user}
    end
  end
  # Don't send unknown messages
  def handle_cast({unknown, user_for, message}, user) do
    Logger.warn "User #{user.name}(#{user.slack}) received unhandled message: #{inspect {unknown, user_for, message}}"
    {:noreply, user}
  end

  def handle_cast({:help, message}, user) do
    {new_config, reply} = handle_message(message |> String.downcase |> String.split(" "), user.config)
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

  defp configured_to_send_message(type, user_for, user) do
    config_self = if (config_self = Map.get(user.config, :"#{type}_self")) != nil, do: config_self, else: true
    config_monitors = if (config_monitors = Map.get(user.config, :"#{type}_monitors")) != nil, do: config_monitors, else: true
    user.slack == user_for && config_self || user.slack != user_for && config_monitors
  end

  # Client API

  def notification(user_pid, {type, user, message}) do
    GenServer.cast user_pid, {type, user, message}
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
