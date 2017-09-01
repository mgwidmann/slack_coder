defmodule SlackCoder.Slack do
  use Slack
  import StubAlias
  import SlackCoder.Slack.Helper
  alias SlackCoder.Slack.Routing
  stub_alias SlackCoder.Users.Supervisor, as: Users
  stub_alias SlackCoder.Users.User
  alias SlackCoder.Models.Message
  alias SlackCoder.Models.User, as: UserModel
  alias SlackCoder.Services.UserService
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
  def send_to(user, message) when is_atom(user), do: user |> to_string() |> send_to(message)
  def send_to(user, notification = %SlackCoder.Github.Notification{}) do
    user_pid = user |> String.to_atom() |> Users.user()
    if user_pid do
      User.notification user_pid, notification
    else
      Logger.error "Attempt to deliver message to #{inspect user}, but pid cannot be found. Notification: #{inspect notification}"
    end
  end
  def send_to(user, message) when is_binary(message), do: send_to(user, %{text: message})
  def send_to(user, raw_message) when is_map(raw_message) do
    send :slack, {user, if Mix.env == :dev do
                          Map.put(raw_message, :text, (raw_message[:text] || "") <> "\n*DEV MESSAGE*")
                        else
                          raw_message
                        end}
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

  def handle_info({user, message}, slack, %{caretaker_id: caretaker_id} = state) do
    user = if(Mix.env == :dev, do: Application.get_env(:slack_coder, :caretaker) |> to_string(), else: user)
    {:ok, "@" <> user
          |> Slack.Lookups.lookup_user_id(slack)
          |> send_message_to_slack_user(user, message, caretaker_id, slack)
          |> case do
              :ok -> state
              {:update, user} -> Map.put(state, :undeliverable, Enum.uniq([{user, message} | Map.get(state, :undeliverable, [])]))
            end
          }
  end
  def handle_info(message, _slack, state) do
    Logger.warn "Got unhandled (handle_info) message: #{inspect message}"
    {:ok, state}
  end

  defp send_message_to_slack_user(nil, user, _message, caretaker_id, slack) do
    send_message("I can't find a user named `@#{user}`, can you tell me what their slack name is?", im(slack, caretaker_id).id, slack)
    {:update, user}
  end
  defp send_message_to_slack_user(slack_user_id, user, message, _caretaker_id, slack) when is_map(message) do
    message = message |> Map.merge(%{channel: Slack.Lookups.lookup_direct_message_id(slack_user_id, slack), type: "message"})

    Task.Supervisor.start_child SlackCoder.TaskSupervisor, __MODULE__, :record_message, [user, message]

    deliver_message(user, message, slack)

    :ok
  end

  @new_message_timeout 1_000
  defp deliver_message(user, %{channel: nil} = message, slack) do
    "@" <> user
    |> Slack.Lookups.lookup_user_id(slack)
    |> case do
      nil ->
        Logger.error "Unable to send message to #{inspect user}!"
      user ->
        case Slack.Web.Im.open(user) do
          %{"ok" => true, "channel" => %{"id" => dm}} when is_binary(dm) ->
            Task.start fn ->
              Process.sleep(@new_message_timeout)
              send_to(user, message) # Need slack data to update
            end
          error ->
            Logger.warn("Unable to open direct message to #{inspect user}! API Response: #{inspect error}")
        end
    end
  end
  defp deliver_message(_user, %{attachments: attachments, channel: channel} = message, _slack) do
    Task.start fn ->
      payload = %{attachments: Poison.encode!(attachments),
                  username: "zombie-bot",
                  icon_url: "https://ca.slack-edge.com/T02UFCF23-U0B5HU9U0-e6e946e40c02-72"}
      Slack.Web.Chat.post_message channel, message[:text], payload
    end
  end
  defp deliver_message(_user, message, slack) when is_map(message) do
    message
    |> Poison.encode!()
    |> send_raw(slack)
  end

  @doc false
  def record_message(user, message) when is_map(message) do
    record_message(user, Poison.encode!(message))
  end
  def record_message(user, message) do
    import Ecto.Query

    github = UserModel.by_slack(user) |> select([u], u.github) |> Repo.one

    Logger.info "Sending message (#{user}): #{message}"

    %Message{}
    |> Message.changeset(%{slack: to_string(user), user: github, message: message |> String.trim})
    |> Repo.insert!
  end

  @doc false
  def handle_close(reason, slack, _state) do
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
    caretaker = user(slack, Application.get_env(:slack_coder, :caretaker))
    {:ok, %{caretaker_id: caretaker.id, undeliverable: []}}
  end

  # TODO: Would like to extract this to a separate module and/or process
  @doc false
  # Caretaker says yes to confirm name
  def handle_event(%{type: "message", text: yes, user: user_id}, slack, %{caretaker_id: user_id, undeliverable: [{:user, username, {github, message}} | users]} = state) when yes in ["yes", "y", "YES", "Y"] do
    resolve_user_update(github, username)
    send_message("Confirmed!", im(slack, user_id).id, slack)
    send_to(username, message)
    {:ok, Map.put(state, :undeliverable, users)}
  end
  # Caretaker says no to confirm name
  def handle_event(%{type: "message", text: no, user: user_id}, slack, %{caretaker_id: user_id, undeliverable: [{:user, _username, {github, _message} = undeliverable} | users]} = state) when no in ["no", "n", "NO", "N"] do
    send_message("Whops! So then who is #{github}?", im(slack, user_id).id, slack)
    {:ok, Map.put(state, :undeliverable, [undeliverable | users])}
  end
  # Caretaker answers incorrectly
  def handle_event(%{type: "message", text: _wrong_username, user: user_id}, slack, %{caretaker_id: user_id, undeliverable: [{:user, username, {github_user, _message}} | _]} = state) do
    send_message("I'm sorry, I'm not following... Just to confirm, the Github user `#{github_user}` is named `@#{username}` on slack? (yes/no)", im(slack, user_id).id, slack)
    {:ok, state}
  end
  # Caretaker answers slack name
  def handle_event(%{type: "message", text: username, user: user_id}, slack, %{caretaker_id: user_id, undeliverable: [{github_user, _message} = undeliverable | users]} = state) do
    send_message("Great! Just to confirm, the Github user `#{github_user}` is named `@#{username}` on slack? (yes/no)", im(slack, user_id).id, slack)
    {:ok, Map.put(state, :undeliverable, [{:user, username, undeliverable} | users])}
  end
  # Any other incoming message
  def handle_event(%{type: "message", text: message, user: user_id, channel: channel} = payload, slack, state) do
    Logger.info [IO.ANSI.green, IO.ANSI.bright, "[Slack] ", IO.ANSI.cyan, IO.ANSI.normal, "Processing Event: #{inspect payload}"]
    user_help(user_id, channel, message, payload, slack)
    {:ok, state}
  end
  def handle_event(payload, _slack, state) do
    Logger.debug [IO.ANSI.green, IO.ANSI.bright, "[Slack] ", IO.ANSI.cyan, IO.ANSI.normal, "Ignoring Event: #{inspect payload}"]
    {:ok, state}
  end

  defp resolve_user_update(github, slack) do
    github
    |> UserModel.by_github()
    |> Repo.one()
    |> UserModel.changeset(%{slack: slack})
    |> UserService.save()
  end

  defp user_help(user_id, channel, message, payload, slack) do
    if should_respond_to_message?(user_id, channel, slack) && payload[:subtype] == nil do
      slack_name = slack[:users][user_id][:name]
      user_pid = Users.user(slack_name)
      if user_pid do
        User.help(user_pid, message)
      else
        send_to slack_name, """
        Sorry, but I can't chat until you've registered!

        Please register at http://slack-coder.nanoapp.io
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
