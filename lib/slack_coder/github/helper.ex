defmodule SlackCoder.Github.Helper do
  alias SlackCoder.Models.PR
  alias SlackCoder.Models.Commit
  alias SlackCoder.Repo
  alias SlackCoder.Services.CommitService
  require Logger
  require Beaker.TimeSeries

  def get(url, default \\ []) do
    github_config = Application.get_env(:slack_coder, :github)
    full_url = "https://#{github_config[:user]}:#{github_config[:pat]}@api.github.com/#{url}"
    Logger.debug "HTTP Request: curl #{full_url}"
    response = Beaker.TimeSeries.time("Github:RequestTime", fn -> HTTPoison.get(full_url, Accept: "application/vnd.github.com.v3+json") end)
    body = case response do
             {:ok, %HTTPoison.Response{status_code: 200, body: body, headers: headers}} ->
               rate_limit_info(headers)
               body
             {:ok, %HTTPoison.Response{status_code: code, body: body, headers: headers}} ->
               rate_limit_info(headers)
               response = case JSX.decode(body) do
                            {:ok, data} -> data
                            {:error, _} -> %{"message" => body}
                          end
               stack = try(do: throw(:exception), catch: (_ -> System.stacktrace))
               Logger.warn "#{full_url}\nStatus #{code}: #{response["message"]}\n#{Exception.format_stacktrace stack}"
               nil
             {:error, %HTTPoison.Error{reason: reason}} ->
               Logger.error "Failed to fetch: (#{reason}) #{url}"
               nil
           end
    if body do
      JSX.decode!(body)
    else
      default
    end
  end

  defp rate_limit_info(headers) do
    headers = Enum.into(headers, %{}) # Convert to map for access syntax
    {remaining, _} = Integer.parse(headers["X-RateLimit-Remaining"] || "0")
    {total, _} = Integer.parse(headers["X-RateLimit-Limit"] || "1")
    rate_limit_message = fn ->
      {timestamp, _} = Integer.parse(headers["X-RateLimit-Reset"] || "0")
      {:ok, date} = Timex.DateTime.from_seconds(timestamp)
                    |> Timex.Timezone.convert("America/New_York")
                    |> Timex.format("%D %T", Timex.Format.DateTime.Formatters.Strftime)
      "Rate Limit: #{remaining} / #{total} -- Resetting at: #{date}"
    end
    percent_used = remaining / total
    Beaker.TimeSeries.sample("Github:RateLimit", percent_used)
    # Cannot invoke macros w/ apply
    if percent_used > 0.25 do
      Logger.debug rate_limit_message
    else
      Logger.warn rate_limit_message
    end
  end

  def pulls(repo, existing_prs \\ []) do
    me = self
    spawn_link fn->
      send(me, {:pr_response, _pulls(repo, existing_prs)})
    end
  end

  defp _pulls(repo, existing_prs) do
    users = Repo.all(SlackCoder.Models.User)
            |> Enum.map(&(&1.github))
    owner = Application.get_env(:slack_coder, :repos, [])[repo][:owner]
    Logger.debug "Pulling #{owner}/#{repo} PRs with #{length(existing_prs)} existing"
    get("repos/#{owner}/#{repo}/pulls", existing_prs)
    |> Stream.filter(fn
        %PR{} = pr -> pr
        pr ->
          pr["user"]["login"] in users
      end)
    |> Stream.map(fn(pr)->
        build_pr(pr, Enum.find(existing_prs, &( &1.number == pr["number"] )))
      end)
    |> Enum.to_list
  end

  def status(pr) do
    if can_send_notifications? || pr.latest_commit == nil do
      me = self
      spawn_link fn ->
        send(me, {:commit_results, _status(pr)})
      end
    end
  end

  defp _status(pr) do
    commit = pr
             |> refresh_pr_from_db
             |> get_latest_commit
    response = get("repos/#{pr.owner}/#{pr.repo}/pulls/#{pr.number}", %{})
    refreshed_pr = build_pr(response, pr)
    conflict_notification(pr, refreshed_pr)

    %PR{ refreshed_pr | latest_commit: commit || pr.latest_commit}
  end

  defp refresh_pr_from_db(pr) do
    Repo.get!(PR, pr.id)
  end

  defp get_latest_commit(pr) do
    owner = if(pr.fork, do: pr.github_user, else: pr.owner)
    last_commit = (get("repos/#{owner}/#{pr.repo}/commits?sha=#{pr.branch}") |> List.first)
    commit = if last_commit["sha"] do # 404 returned when user deletes branch
      statuses = (pr.statuses_url <> "#{last_commit["sha"]}") |> get
      last_status = statuses
                    |> Stream.filter(&( &1["context"] =~ ~r/travis/ ))
                    |> Enum.take(1) # List is already sorted, first is the latest
                    |> List.first
      code_climate = statuses
                    |> Stream.filter(&( &1["context"] =~ ~r/codeclimate/ ))
                    |> Enum.take(1) # List is already sorted, first is the latest
                    |> List.first
      commit = if pr.latest_commit && pr.latest_commit.latest_status_id == last_status["id"] do
        pr.latest_commit
      else
        Repo.get_by(Commit, sha: last_commit["sha"]) || %Commit{}
      end
      cs = Commit.changeset(commit, %{
            status: if(pr.mergeable, do: last_status["state"] || "pending", else: "conflict"),
            code_climate_status: code_climate["state"] || "pending",
            travis_url: last_status["target_url"],
            code_climate_url: code_climate["target_url"],
            sha: last_commit["sha"],
            github_user: last_commit["author"]["login"],
            github_user_avatar: last_commit["author"]["avatar_url"],
            latest_status_id: last_status["id"],
            pr_id: pr.id
           })
      {:ok, commit} = CommitService.save(cs)
      commit
    end
    commit || pr.latest_commit
  end

  def conflict_notification(pr, refreshed_pr) do
    user = user_for_pr(pr)
    # Prior was mergeable but now it is not (nil means analysis in process)
    if user && pr.mergeable && refreshed_pr.mergeable == false do
      [message_for | slack_users] = slack_user_with_monitors(user)
      message = ":heavy_multiplication_x: *MERGE CONFLICTS* #{pr.title} \n#{pr.html_url}"
      Logger.debug "Merge conflict for PR-#{pr.number}, sending to: #{inspect message_for}"
      notify(slack_users, :conflict, message_for, message, refreshed_pr)
    end
  end

  def find_latest_comment(%PR{number: number, repo: repo, owner: owner} = pr) do
     latest_issue_comment = get("repos/#{owner}/#{repo}/issues/#{number}/comments") |> List.last
     latest_pr_comment = get("repos/#{owner}/#{repo}/pulls/#{number}/comments") |> List.last
     case {latest_issue_comment, latest_pr_comment} do
       {date1, date2} when date1 != nil or date2 != nil ->
         {which, date} = greatest_date_for(date1["updated_at"], date2["updated_at"])
         {if(which == :first, do: latest_issue_comment, else: latest_pr_comment),
          PR.reg_changeset(pr, %{latest_comment: date})}
       {nil, nil} ->
         {nil, PR.reg_changeset(pr, %{latest_comment: pr.opened_at})}
     end
  end

  defp greatest_date_for(nil, date), do: {:second, date_for(date)}
  defp greatest_date_for(date, nil), do: {:first, date_for(date)}
  defp greatest_date_for(date1, date2) do
    date1 = date_for(date1)
    date2 = date_for(date2)
    case Timex.Date.compare(date1, date2) do
      -1 -> {:second, date2}
      0 -> {:first, date1} # Doesn't matter really
      1 -> {:first, date1}
    end
  end

  defp date_for(nil), do: nil
  defp date_for(string) do
     {:ok, date} = Timex.DateFormat.parse(string, "{ISO}")
     date
  end

  def build_pr(pr), do: build_pr(pr, Repo.get_by(PR, number: pr["number"]) || %PR{})

  def build_pr(pr, nil), do: build_pr(pr)
  def build_pr(pr, %PR{id: id} = existing_pr) when is_integer(id) do
    mergeable = not pr["mergeable_state"] in ["dirty"]
    {:ok, existing_pr} = PR.reg_changeset(existing_pr, %{
                           title: pr["title"],
                           closed_at: date_for(pr["closed_at"]),
                           merged_at: date_for(pr["merged_at"]),
                           mergeable: mergeable
                         })
                         |> Repo.update
    %PR{ existing_pr | github_user_avatar: pr["user"]["avatar_url"] }
  end
  def build_pr(pr, new_pr) do
    github_user = pr["user"]["login"]
    avatar = pr["user"]["avatar_url"]
    repo = pr["base"]["repo"]["name"]
    owner = pr["base"]["repo"]["owner"]["login"]
    # Ecto bug https://github.com/elixir-lang/ecto/issues/1121
    new_pr = %PR{new_pr | github_user_avatar: avatar }
    cs = PR.reg_changeset(new_pr,
      %{number: pr["number"],
        title: pr["title"],
        html_url: pr["_links"]["html"]["href"],
        statuses_url: "repos/#{owner}/#{repo}/statuses/",
        github_user: github_user,
        opened_at: date_for(pr["created_at"]),
        closed_at: date_for(pr["closed_at"]),
        merged_at: date_for(pr["merged_at"]),
        owner: owner,
        repo: repo,
        branch: pr["head"]["ref"],
        fork: pr["head"]["repo"]["owner"]["login"] != pr["base"]["repo"]["owner"]["login"]
      })
    {:ok, new_pr} = Repo.save(cs)
    new_pr
  end

  def now do
    to_local(Timex.DateTime.local)
  end

  def to_local(date) do
    timezone = Application.get_env(:slack_coder, :timezone)
    if Timex.Timezone.exists?(timezone) && date do
      date |> Timex.Timezone.convert(timezone)
    else
      date
    end
  end

  def to_utc(date) do
    date && Timex.Timezone.convert(date, "UTC")
  end

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
  def notify([], type, message_for, message, pr) do
    spawn_link __MODULE__, :notify, [{message_for, type, slack_user_called_out?(message_for, pr), message_for, message, pr}]
  end
  def notify(slack_user, type, message_for, message, pr) do
    spawn_link __MODULE__, :notify, [{slack_user, type, slack_user_called_out?(slack_user, pr), message_for, message, pr}]
  end

  def notify({slack_user, type, called_out, message_for, message, pr}) do
    SlackCoder.Slack.send_to(slack_user, {type, called_out, message_for, message})
  end

  defp slack_user_called_out?(slack_user, pr) do
    SlackCoder.Users.Supervisor.user(slack_user)
    |> SlackCoder.Users.User.get
    |> SlackCoder.Github.Supervisor.called_out?(pr)
  end

  def report_change(commit) do
    pr = Repo.get(PR, commit.pr_id)
    pr = %PR{ pr | latest_commit: commit, github_user_avatar: commit.github_user_avatar } # temporary for view only
    html = SlackCoder.PageView.render("pull_request.html", pr: pr)
    SlackCoder.Endpoint.broadcast("prs:all", "pr:update", %{pr: pr.number, github: pr.github_user, html: Phoenix.HTML.safe_to_string(html)})

    user = user_for_pr(pr)
    if user do
      [message_for | slack_users] = slack_user_with_monitors(user)
      case String.to_atom(commit.status) do
        status when status in [:failure, :error] ->
          message = ":facepalm: *BUILD FAILURE* #{pr.title} :-1:\n#{pr.latest_commit.travis_url}\n#{pr.html_url}"
          notify(slack_users, :fail, message_for, message, pr)
        :success ->
          message = ":bananadance: #{pr.title} :success:\n#{pr.html_url}"
          notify(slack_users, :pass, message_for, message, pr)
        # :pending or ignoring any other unknown statuses
        _ ->
          nil
      end
    end
  end

  def user_for_pr(pr) do
    SlackCoder.Users.Supervisor.user(pr.github_user)
    |> SlackCoder.Users.User.get
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
    SlackCoder.Users.Supervisor.users
    |> Stream.filter(&(user.github in &1.monitors))
    |> Enum.map(&(Map.get(&1, map_to)))
  end

end
