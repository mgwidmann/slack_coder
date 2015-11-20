defmodule SlackCoder.Github.Supervisor do
  import Supervisor.Spec
  require Logger

  def start_link() do
    repos = Application.get_env(:slack_coder, :repos, []) |> Keyword.keys
    children = repos |> Enum.map(fn(repo)->
      worker(SlackCoder.Github.Watchers.Repository, [repo], id: "Repo-#{repo}")
    end)

    opts = [strategy: :one_for_one, name: SlackCoder.Github.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def start_watcher(pr) do
    case Supervisor.start_child(SlackCoder.Github.Supervisor,
      worker(SlackCoder.Github.Watchers.PullRequest, [pr], id: "PR-#{pr.number}")) do
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
            |> Enum.find(&(match?({"PR-" <> ^number, _, _, _}, &1)))
    case child do
      nil -> nil
      {_, worker, _, _} -> worker
    end
  end

  def pull_requests() do
    Supervisor.which_children(SlackCoder.Github.Supervisor)
    |> Stream.filter(fn
      {"PR-" <> _number, _, _, _} -> true
      _ -> false
    end)
    |> Stream.map(fn
      {_, pid, _, _} ->
        SlackCoder.Github.Watchers.PullRequest.fetch(pid)
    end)
    |> Stream.filter(&(&1)) # Remove nils
    |> Enum.reduce(%{}, fn
      pr, prs ->
        user = pr.github_user |> String.to_atom
        list = prs[user] || []
        Map.put(prs, user, [pr | list])
    end)
  end

end
