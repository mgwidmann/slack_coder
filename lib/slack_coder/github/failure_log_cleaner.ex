defmodule SlackCoder.Github.FailureLogCleaner do
  use GenServer
  alias SlackCoder.Repo
  alias SlackCoder.Models.{RandomFailure, RandomFailure.FailureLog}

  def start_link() do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @clean_interval 60_000 * 5 # 5 minutes
  def init(_) do
    Process.send_after(self(), :clean_logs, @clean_interval)
    {:ok, nil}
  end

  def handle_info(:clean_logs, _) do
    clean_logs()
    Process.send_after(self(), :clean_logs, @clean_interval)
    {:noreply, nil}
  end

  def clean_logs() do
    import Ecto.Query
    random_failure_ids = from(r in RandomFailure, where: not is_nil(r.failure_log_id), select: r.failure_log_id, distinct: true) |> Repo.all
    log_ids = from(log in FailureLog, join: pr in PR, on: pr.id == log.pr_id and pr.sha != log.sha, where: not log.id in ^random_failure_ids, select: log.id) |> Repo.all
    Repo.delete_all(from log in FailureLog, where: log.id in ^log_ids)
  end
end
