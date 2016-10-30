defmodule SlackCoder.Github.Watchers.Supervisor do
  import Supervisor.Spec
  alias SlackCoder.Repo
  alias SlackCoder.Models.PR
  require Logger

  def start_link() do
    prs = Repo.all PR.active
    children = prs |> Enum.map(&worker_for/1)

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end

  defp worker_for(pr) do
    worker(SlackCoder.Github.Watchers.PullRequest, [pr], id: worker_id(pr), restart: :transient)
  end

  @worker_id_prefix "PR-"
  defp worker_id(pr), do: "#{@worker_id_prefix}#{pr.number}"

  def start_watcher(pr) do
    case Supervisor.start_child(__MODULE__, worker_for(pr)) do
        {:ok, watcher} ->
          Logger.debug "Starting watcher for: #{worker_id(pr)} #{pr.title}"
          watcher
        {:error, {:already_started, watcher}} ->
          watcher
        {:error, :already_present} ->
          find_watcher(pr)
    end
  end

  def stop_watcher(nil), do: nil
  def stop_watcher(pr) do
    Supervisor.terminate_child(__MODULE__, worker_id(pr))
    Supervisor.delete_child(__MODULE__, worker_id(pr))
  end

  def find_or_start_watcher(pr) do
    case find_watcher(pr) do
      nil -> start_watcher(pr)
      pid -> pid
    end
  end

  def find_watcher(pr) do
    number = pr.number |> to_string
    child = Supervisor.which_children(__MODULE__)
            |> Enum.find(&(match?({@worker_id_prefix <> ^number, _, _, _}, &1)))
    case child do
      nil -> nil
      {_, worker, _, _} -> worker
    end
  end

  def pull_requests() do
    Supervisor.which_children(__MODULE__)
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

  # def called_out?(%SlackCoder.Models.User{github: github}, pr) do
  #   find_watcher(pr)
  #   |> SlackCoder.Github.Watchers.PullRequest.is_called_out?(github)
  # end

end
