defmodule SlackCoder.Github.Notification do
  import SlackCoder.Github.TimeHelper
  import StubAlias
  stub_alias SlackCoder.Users.User
  stub_alias SlackCoder.Users.Supervisor, as: Users
  alias SlackCoder.Travis.Build

  defstruct [:slack_user, :type, :called_out?, :message_for, :message]

  ### NOTIFICATIONS ###

  def conflict(pr) do
    case user_for_pr(pr) |> slack_user_with_monitors do
      [message_for | slack_users] ->
        message = %{
                    attachments: [
                      %{
                        author_name: ":heavy_multiplication_x: MERGE CONFLICTS",
                        color: "#999999",
                        fallback: "MERGE CONFLICTS #{pr.title}",
                        title: pr.title,
                        title_link: pr.html_url
                      }
                    ]
                  }
        notify(slack_users, :conflict, message_for, message, pr)
        pr
      _ -> pr
    end
  end

  def failure(pr) do
    case user_for_pr(pr) |> slack_user_with_monitors do
      [message_for | slack_users] ->
        %{"build_id" => build_id} = Regex.named_captures(~r/(?<build_id>\d+)/, pr.build_url)
        failed_jobs = SlackCoder.Travis.build_info(pr.owner, pr.repo, build_id)
                      |> Enum.filter(&match?(%Build{result: :failure}, &1))
                      |> Enum.map(fn build ->
                        SlackCoder.Travis.job_log(build)
                      end)
        message = %{
                    attachments: [
                      %{
                        author_name: ":-1: FAILURE",
                        color: "#FF0000",
                        fallback: "FAILURE #{pr.title}",
                        title: pr.title,
                        title_link: pr.html_url,
                        text: """
                        <#{pr.build_url}|Travis Build>
                        ```
                        #{Enum.join(failed_jobs, "\n")}
                        ```
                        """,
                        mrkdwn_in: ["text"],
                        footer: "#{Enum.sum(Enum.map(failed_jobs, &(Enum.count(&1.rspec))))} rspec, #{Enum.sum(Enum.map(failed_jobs, &(Enum.count(&1.cucumber))))} cucumber"
                      }
                    ]
                  }
        notify(slack_users, :fail, message_for, message, pr)
        pr
      _ -> pr
    end
  end

  def success(pr) do
    case user_for_pr(pr) |> slack_user_with_monitors do
      [message_for | slack_users] ->
        message = %{
                    attachments: [
                      %{
                        fallback: "SUCCESS #{pr.title}",
                        author_name: ":tada: SUCCESS",
                        color: "#77DD33",
                        title: pr.title,
                        title_link: pr.html_url
                      }
                    ]
                  }
        notify(slack_users, :pass, message_for, message, pr)
        pr
      _ -> pr
    end
  end

  def merged(pr) do
    case user_for_pr(pr) |> slack_user_with_monitors do
      [message_for | slack_users] ->
        message = %{
                    attachments: [
                      %{
                        fallback: "MERGED #{pr.title}",
                        author_name: ":smiling_imp: MERGED",
                        color: "#9a009a",
                        title: pr.title,
                        title_link: pr.html_url
                      }
                    ]
                  }
        notify(slack_users, :merge, message_for, message, pr)
        pr
      _ -> pr
    end
  end

  def closed(pr) do
    case user_for_pr(pr) |> slack_user_with_monitors do
      [message_for | slack_users] ->
        message = %{
                    attachments: [
                      %{
                        fallback: "CLOSED #{pr.title}",
                        author_name: ":rage: CLOSED",
                        color: "#FF4500",
                        title: pr.title,
                        title_link: pr.html_url
                      }
                    ]
                  }
        notify(slack_users, :merge, message_for, message, pr)
        pr
      _ -> pr
    end
  end

  def stale(pr) do
    case user_for_pr(pr) |> slack_user_with_monitors do
      [message_for | slack_users] ->
        stale_hours = Timex.diff(pr.latest_comment, now(), :hours)
        message = %{
                    attachments: [
                      %{
                        fallback: "STALE #{pr.title}",
                        author_name: ":hankey: STALE",
                        color: "#DDDDDD",
                        title: pr.title,
                        title_link: pr.html_url,
                        text: "Stale for *#{stale_hours}* hours",
                        mrkdwn_in: ["text"]
                      }
                    ]
                  }
        notify(slack_users, :stale, message_for, message, pr)
        pr
      _ -> pr
    end
  end

  def unstale(pr) do
    case user_for_pr(pr) |> slack_user_with_monitors do
      [message_for | slack_users] ->
        message = %{
                    attachments: [
                      %{
                        fallback: "ACTIVE #{pr.title}",
                        author_name: ":email: ACTIVE",
                        color: "#000000",
                        title: pr.title,
                        title_link: pr.html_url
                      }
                    ]
                  }
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

  def slack_user_with_monitors(nil), do: []
  def slack_user_with_monitors(user) do
    message_for = user.slack
    users = user_with_monitors(user, :slack)
    Enum.uniq([message_for | users])
  end

  def github_user_with_monitors(nil), do: []
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
