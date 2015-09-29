defmodule SlackCoder.Github.Supervisor do
  import Supervisor.Spec
  alias SlackCoder.Github.PullRequest.Commit
  require Logger

  def start_link() do
    IO.puts "#{__MODULE__}.start_link"
    repos = Application.get_env(:slack_coder, :repos, []) |> Keyword.keys
    children = repos |> Enum.map(fn(repo)->
      worker(SlackCoder.Github.PullRequest, [repo], id: "Repo-#{repo}")
    end)

    opts = [strategy: :one_for_one, name: SlackCoder.Github.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def start_watcher(pr) do
    case Supervisor.start_child(SlackCoder.Github.Supervisor,
      worker(SlackCoder.Github.PullRequest.Watcher, [pr], id: "PR-#{pr.number}")) do
        {:ok, watcher} ->
          Logger.debug "Starting watcher for: PR-#{pr.number} #{pr.title}"
          watcher
        {:error, {:already_started, watcher}} ->
          watcher
        {:error, :already_present} ->
          find_watcher(pr)
    end
  end

  def stop_watcher(pr) do
    Supervisor.terminate_child(SlackCoder.Github.Supervisor, "PR-#{pr.number}")
  end

  def find_watcher(pr) do
    number = pr.number
    child = Supervisor.which_children(SlackCoder.Github.Supervisor)
            |> Enum.find(fn
              {"PR-" <> number, _, _, _} -> true
              _ -> false
            end)
    case child do
      nil -> nil
      {_, worker, _, _} -> worker
    end
  end

  def pull_requests() do
    Supervisor.which_children(SlackCoder.Github.Supervisor)
    |> Stream.filter(fn
      {"PR-" <> number, _, _, _} -> true
      _ -> false
    end)
    |> Stream.map(fn
      {_, pid, _, _} ->
        SlackCoder.Github.PullRequest.Watcher.fetch(pid)
    end)
    |> Stream.filter(&(&1)) # Remove nils
    |> Enum.reduce(%{}, fn
      %Commit{github_user: user} = commit, prs ->
        list = prs[user] || []
        Map.put(prs, user, [commit | list])
    end)
  end

end
