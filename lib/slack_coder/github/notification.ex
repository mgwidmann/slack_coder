defmodule SlackCoder.Github.Notification do
  import SlackCoder.Github.TimeHelper
  import StubAlias
  stub_alias SlackCoder.Users.User
  stub_alias SlackCoder.Users.Supervisor, as: Users

  defstruct [:slack_user, :type, :called_out?, :message_for, :message]

  ### NOTIFICATIONS ###

  def conflict(pr) do
    case user_for_pr(pr) |> slack_user_with_monitors do
      [message_for | slack_users] ->
        message = ":heavy_multiplication_x: *MERGE CONFLICTS* *#{pr.title}* \n#{pr.html_url}"
        notify(slack_users, :conflict, message_for, message, pr)
        pr
      _ -> pr
    end
  end

  def failure(pr) do
    case user_for_pr(pr) |> slack_user_with_monitors do
      [message_for | slack_users] ->
        message = ":facepalm: *FAILURE* *#{pr.title}* :-1:\n#{pr.build_url}\n#{pr.html_url}"
        notify(slack_users, :fail, message_for, message, pr)
        pr
      _ -> pr
    end
  end

  def success(pr) do
    case user_for_pr(pr) |> slack_user_with_monitors do
      [message_for | slack_users] ->
        message = ":bananadance: *SUCCESS* *#{pr.title}* :success:\n#{pr.html_url}"
        notify(slack_users, :pass, message_for, message, pr)
        pr
      _ -> pr
    end
  end

  def merged(pr) do
    case user_for_pr(pr) |> slack_user_with_monitors do
      [message_for | slack_users] ->
        message = """
        :smiling_imp: *MERGED* *#{pr.title}* :raveparrot:
        #{pr.html_url}
        """
        notify(slack_users, :merge, message_for, message, pr)
        pr
      _ -> pr
    end
  end

  def closed(pr) do
    case user_for_pr(pr) |> slack_user_with_monitors do
      [message_for | slack_users] ->
        message = """
        :rage: *CLOSED* *#{pr.title}* :angry:
        #{pr.html_url}
        """
        notify(slack_users, :merge, message_for, message, pr)
        pr
      _ -> pr
    end
  end

  def stale(pr) do
    case user_for_pr(pr) |> slack_user_with_monitors do
      [message_for | slack_users] ->
        stale_hours = Timex.Date.diff(pr.latest_comment, now, :hours)
        message = """
        :hankey: *#{pr.title}*
        Stale for *#{stale_hours}* hours
        #{pr.html_url}
        """
        notify(slack_users, :stale, message_for, message, pr)
        pr
      _ -> pr
    end
  end

  def unstale(pr) do
    case user_for_pr(pr) |> slack_user_with_monitors do
      [message_for | slack_users] ->
        message = ":email: *CHATTER* *#{pr.title}* :memo:\n#{pr.latest_comment_url || pr.html_url}"
        notify(slack_users, :unstale, message_for, message, pr)
        pr
      _ -> pr
    end
  end

  ### HELPERS ###

  if Application.get_env(:slack_coder, :notifications)[:always_allow] do
    def can_send_notifications?(), do: true
  else
    @weekdays (Application.get_env(:slack_coder, :notifications)[:days] || [1,2,3,4,5]) |> Enum.map(&Timex.day_name(&1))
    @min_hour Application.get_env(:slack_coder, :notifications)[:min_hour] || 8
    @max_hour Application.get_env(:slack_coder, :notifications)[:max_hour] || 17
    def can_send_notifications?() do
      day_name = now |> Timex.weekday |> Timex.day_name
      day_name in @weekdays && now.hour >= @min_hour && now.hour <= @max_hour
    end
  end

  def notify([slack_user | users], type, message_for, message, pr) do
    notify(slack_user, type, message_for, message, pr)
    notify(users, type, message_for, message, pr)
  end
  def notify([], type, message_for, message, _pr) do
    Task.start fn ->
      notify(%__MODULE__{
        slack_user: message_for,
        type: type,
        message_for: message_for,
        message: message
      })
    end
  end
  def notify(slack_user, type, message_for, message, _pr) do
    Task.start fn ->
      notify(%__MODULE__{
        slack_user: slack_user,
        type: type,
        message_for: message_for,
        message: message
      })
    end
  end

  def notify(notification = %__MODULE__{slack_user: slack_user}) do
    SlackCoder.Slack.send_to(slack_user, notification)
  end

  def slack_user_with_monitors(user) do
    message_for = user.slack
    users = user_with_monitors(user, :github)
    Enum.uniq([message_for | users])
  end

  def github_user_with_monitors(user) do
    message_for = user.github
    users = user_with_monitors(user, :github)
    Enum.uniq([message_for | users])
  end

  defp user_with_monitors(user, map_to) do
    Users.users
    |> Stream.filter(&(user.github in &1.monitors))
    |> Enum.map(&(Map.get(&1, map_to)))
  end

  def user_for_pr(pr) do
    Users.user(pr.github_user)
    |> User.get
  end

end
