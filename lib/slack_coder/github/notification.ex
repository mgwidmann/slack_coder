defmodule SlackCoder.Github.Notification do
  import SlackCoder.Github.TimeHelper
  import StubAlias
  stub_alias SlackCoder.Users.User
  stub_alias SlackCoder.Users.Supervisor, as: Users
  alias SlackCoder.BuildSystem.File
  stub_alias SlackCoder.Github
  stub_alias SlackCoder.Slack

  defstruct [:slack_user, :type, :called_out?, :message_for, :message]

  ### NOTIFICATIONS ###

  def conflict(pr) do
    case user_for_pr(pr) |> slack_user_with_monitors do
      [message_for | slack_users] ->
        message = %{
                    attachments: [
                      %{
                        author_name: "✖︎ MERGE CONFLICTS",
                        author_icon: pr.user.avatar_url,
                        color: "#999999",
                        fallback: "✖︎ MERGE CONFLICTS #{pr.title}",
                        title: pr.title,
                        title_link: pr.html_url,
                        footer: "#{pr.owner}/#{pr.repo}:#{pr.base_branch}"
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
        message = %{
                    attachments: [
                      %{
                        author_name: "👎 FAILURE",
                        author_icon: pr.user.avatar_url,
                        color: "#FF0000",
                        fallback: "👎 FAILURE #{pr.title}",
                        title: pr.title,
                        title_link: pr.html_url,
                        text: """
                        <#{pr.build_url}|Travis Build>
                        """,
                        mrkdwn_in: ["text"],
                        footer: "#{footer_text SlackCoder.BuildSystem.counts(pr.last_failed_jobs)} #{pr.owner}/#{pr.repo}:#{pr.base_branch}"
                      } | failures(pr)
                    ]
                  }
        notify(slack_users, :fail, message_for, message, pr)
        pr
      _ -> pr
    end
  end

  defp failures(pr) do
    for {failure_log_id, files} <- pr.last_failed_jobs |> Enum.uniq_by(&(&1.file)) |> Enum.group_by(&(&1.failure_log_id)) do
      %{
        color: "#FF0000",
        text: """
        #{failed_job_output(files)}
        #{view_log_action(failure_log_id)}
        """,
        mrkdwn_in: ["text"],
      }
    end
  end

  defp footer_text(failed_jobs) do
    failed_jobs
    |> Map.to_list
    |> Enum.map(fn t -> t |> Tuple.to_list |> Enum.reverse |> Enum.join(" ") end)
    |> Enum.join(", ")
  end

  defp failed_job_output([]), do: ""
  defp failed_job_output(%File{} = file), do: failed_job_output([file])
  defp failed_job_output(failed_jobs) when is_list(failed_jobs) do
    grouped = failed_jobs |> List.flatten() |> Enum.group_by(&(&1.type))
    """
    ```
    #{Enum.map(grouped, &executable/1) |> Enum.join("\n")}
    ```
    """
  end

  def executable({:rspec, files}) do
    files
    |> Enum.group_by(&(&1.seed))
    |> Enum.map(fn {seed, files} ->
      "bundle exec rspec#{files |> Enum.map(&(&1.file)) |> files_to_string()} --seed #{seed}"
    end)
    |> Enum.join("\n")
  end
  def executable({:cucumber, files}) do
    "bundle exec cucumber#{files |> Enum.map(&(&1.file)) |> files_to_string()}"
  end
  def executable({:minitest, files}) do
    files
    |> Enum.group_by(&(&1.seed))
    |> Enum.map(fn {seed, files} ->
      "bin/rails test #{files |> Enum.map(&(&1.file)) |> files_to_string()} TESTOPTS=\"--seed #{}\""
    end)
    |> Enum.join("\n")
  end

  defp files_to_string(list, acc \\ "")
  defp files_to_string([], acc), do: acc
  defp files_to_string([{file, "[" <> _ = line, _desc} | rest], acc), do: files_to_string(rest, acc <> " " <> file <> line)
  defp files_to_string([{file, line, _desc} | rest], acc), do: files_to_string(rest, acc <> " " <> file <> ":" <> line)

  def random_failure(pr, previously_resolved) do
    failed_count = pr.last_failed_jobs |> length()
    failure_message = "🚀 #{failed_count} RANDOM NUCLEAR #{plural_failures(failed_count)} DETECTED #{if(previously_resolved, do: "(Previously Resolved)")}"
    message = %{
                attachments: [
                  %{
                    author_name: failure_message,
                    author_icon: pr.user.avatar_url,
                    color: "#FF0000",
                    fallback: failure_message,
                    title: pr.title,
                    title_link: pr.html_url,
                    footer: "#{footer_text SlackCoder.BuildSystem.counts(pr.last_failed_jobs)} #{pr.owner}/#{pr.repo}:#{pr.base_branch}"
                  } | blame_attachments(pr)]
              }
    Slack.send_to_channel(Application.get_env(:slack_coder, :random_failure_channel), message)
  end

  defp plural_failures(count) when count >= 2, do: "FAILURES"
  defp plural_failures(_count), do: "FAILURE"

  defp view_log_action(nil), do: ""
  defp view_log_action(failure_log_id) do
    "<#{SlackCoder.Router.Helpers.random_failure_url(SlackCoder.Endpoint, :log, failure_log_id)}|View Log>"
  end

  @max_blames 19
  defp blame_attachments(pr) do
    for %File{file: file_descriptor, failure_log_id: failure_log_id} = file <- Enum.uniq_by(pr.last_failed_jobs, &(&1.file)) |> Enum.take(@max_blames) do
      {file_name, line, _description} = file_descriptor
      case Integer.parse(line) do
        {line, ""} ->
          case Github.blame(pr.owner, pr.repo, pr.last_failed_sha, file_name, line) do
            %{"avatarUrl" => avatar, "user" => %{"name" => name}} ->
              %{
                author_name: "#{name} wrote test #{file_name}:#{line}",
                author_icon: avatar,
                color: "#FF0000",
                text: """
                #{failed_job_output(file)}
                #{view_log_action(failure_log_id)}
                """,
                mrkdwn_in: ["text"]
          		}
            _ -> nil
          end
        :error ->
          nil
      end
    end
    |> Enum.filter(&(&1))
  end

  def success(pr) do
    case user_for_pr(pr) |> slack_user_with_monitors do
      [message_for | slack_users] ->
        message = %{
                    attachments: [
                      %{
                        fallback: "🎉 SUCCESS #{pr.title}",
                        author_name: "🎉 SUCCESS",
                        author_icon: pr.user.avatar_url,
                        color: "#77DD33",
                        title: pr.title,
                        title_link: pr.html_url,
                        footer: "#{pr.owner}/#{pr.repo}:#{pr.base_branch}"
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
                        fallback: "😈 MERGED #{pr.title}",
                        author_icon: pr.user.avatar_url,
                        author_name: "😈 MERGED",
                        color: "#9a009a",
                        title: pr.title,
                        title_link: pr.html_url,
                        footer: "#{pr.owner}/#{pr.repo}:#{pr.base_branch}"
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
                        fallback: "😡 CLOSED #{pr.title}",
                        author_icon: pr.user.avatar_url,
                        author_name: "😡 CLOSED",
                        color: "#FF4500",
                        title: pr.title,
                        title_link: pr.html_url,
                        footer: "#{pr.owner}/#{pr.repo}:#{pr.base_branch}"
                      }
                    ]
                  }
        notify(slack_users, :close, message_for, message, pr)
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
                        fallback: "💩 STALE #{pr.title}",
                        author_name: "💩 STALE",
                        author_icon: pr.user.avatar_url,
                        color: "#DDDDDD",
                        title: pr.title,
                        title_link: pr.html_url,
                        text: "Stale for *#{stale_hours}* hours",
                        mrkdwn_in: ["text"],
                        footer: "#{pr.owner}/#{pr.repo}:#{pr.base_branch}"
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
                        fallback: "✉️ ACTIVE #{pr.title}",
                        author_name: "✉️ ACTIVE",
                        author_icon: pr.user.avatar_url,
                        color: "#000000",
                        title: pr.title,
                        title_link: pr.html_url,
                        footer: "#{pr.owner}/#{pr.repo}:#{pr.base_branch}"
                      }
                    ]
                  }
        notify(slack_users, :unstale, message_for, message, pr)
        pr
      _ -> pr
    end
  end

  def open(pr) do
    case user_for_pr(pr) |> slack_user_with_monitors do
      [message_for | slack_users] ->
        message = %{
                    attachments: [
                      %{
                        fallback: "👀 OPENED #{pr.title}",
                        author_name: "👀 OPENED",
                        author_icon: pr.user.avatar_url,
                        color: "#0000FF",
                        title: pr.title,
                        title_link: pr.html_url,
                        footer: "#{pr.owner}/#{pr.repo}:#{pr.base_branch}"
                      }
                    ]
                  }
        notify(slack_users, :open, message_for, message, pr)
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
