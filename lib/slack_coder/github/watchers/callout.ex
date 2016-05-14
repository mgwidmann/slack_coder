defmodule SlackCoder.Github.Watchers.Callout do
  use GenServer
  use Timex
  import Ecto.Query, only: [from: 2]
  alias SlackCoder.Repo
  alias Tentacat.Issues.Comments
  alias Tentacat.Pulls.Comments, as: PullComments
  alias SlackCoder.Github
  alias SlackCoder.Github.Watchers.PullRequest.Helper
  require Logger

  @poll_minutes 1
  @poll_interval 60_000 * @poll_minutes # 5 minutes

  def start_link(repo) do
    GenServer.start_link __MODULE__, repo
  end

  def init(repo) do
    send(self, :load_users)
    :timer.send_interval @poll_interval, :callouts
    {:ok, %{repo: repo, github_users: [], last_checked: DateTime.local}}
  end

  def handle_info(:load_users, state) do
    users = from(u in SlackCoder.Models.User, select: u.github) |> Repo.all
    {:noreply, Map.put(state, :github_users, users)}
  end

  def handle_info(:callouts, state) do
    owner = Application.get_env(:slack_coder, :repos, [])[state.repo][:owner]

    {:ok, since} = Timex.format(state.last_checked, "{ISOz}")

    success = try do
      Comments.filter_all(owner, state.repo, %{since: since}, Github.client)
      |> Enum.map(&( {issue_number(&1["issue_url"]), &1["body"]} ))
      |> start_watchers(state.github_users, {state.repo, owner})
      true
    rescue # Rate limiting from Github causes exceptions, until a better solution
      e -> # within Tentacat presents itself, just log the exception...
        Logger.error "Error updating Callouts: #{Exception.message(e)}\n#{Exception.format_stacktrace}"
        false
    end

    {:noreply, if(success, do: Map.put(state, :last_checked, DateTime.local), else: state)}
  end

  defp issue_number(url), do: String.split(url, "/") |> List.last |> String.to_integer

  defp start_watchers([], _, _), do: nil
  defp start_watchers([{pr_number, comment} | comments], github_users, {repo, owner}) do
    github_users
    |> Enum.each(fn(user)->
      if comment =~ ~r/@#{user}/, do: watch_pr(user, pr_number, {repo, owner})
    end)

    start_watchers(comments, github_users, {repo, owner})
  end

  defp watch_pr(github_user, pr_number, {repo, owner}) do
    pr = PullComments.list(owner, repo, pr_number, Github.client) |> Helper.build_or_update

    SlackCoder.Github.Supervisor.start_watcher(pr)
    |> SlackCoder.Github.Watchers.PullRequest.add_callout(github_user)
  end

end
