defmodule SlackCoder.Users.User do
  use GenServer
  alias SlackCoder.Repo
  alias SlackCoder.Models.User
  alias SlackCoder.Models.User.Config
  alias SlackCoder.Slack
  import SlackCoder.Users.Help

  # Server API

  def start_link(user) do
    GenServer.start_link __MODULE__, user
  end

  def init(user) do
    github = SlackCoder.Config.github_user(user)
    user = user |> User.by_slack |> Repo.one
    unless user do
      {:ok, user} = Repo.insert(User.changeset(%User{}, %{slack: to_string(user), github: to_string(github), config: %{}}))
    end
    {:ok, user}
  end

  for type <- [:stale, :build] do
    def handle_cast({unquote(type), {user_for, message}}, user) do
      if configured_to_send_message(unquote(type), user_for, user) do
        Slack.send_to(user.slack, message)
      end
      {:noreply, user}
    end
  end

  def handle_cast({:help, message}, user) do
    user = handle_message(String.split(message, " "), user)
    {:noreply, user}
  end

  defp configured_to_send_message(type, user_for, user) do
    user.slack == user_for && apply(Config, :"#{type}_self", [user]) || user.slack != user_for && apply(Config, :"config_#{type}_monitors", [user])
  end

  # Client API

  def stale_pr_notification(user_pid, {user, message}) do
    GenServer.cast user_pid, {:stale, {user, message}}
  end

  def build_notification(user_pid, {user, message}) do
    GenServer.cast user_pid, {:build, {user, message}}
  end

  def help(user_pid, message) do
    GenServer.cast user_pid, {:help, message}
  end

end
