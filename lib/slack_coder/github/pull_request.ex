defmodule SlackCoder.Github.PullRequest do
  use GenServer
  import SlackCoder.Github.Helper
  alias SlackCoder.Github.PullRequest.PR
  require Logger

  @poll_interval 60_000 * 5 # 5 minutes

  def start_link(repo) do
    GenServer.start_link __MODULE__, repo
  end

  def init(repo) do
    pulls(repo) # Async fetch
    :timer.send_interval @poll_interval, :update_prs
    {:ok, {repo, []}}
  end

  def handle_info({:pr_response, prs}, {repo, _prs}) do
    prs = prs
          |> Enum.map fn
               %PR{watcher: nil} = pr ->
                 Logger.debug "Starting watcher for: PR-#{pr.number} #{pr.title}"
                 {:ok, watcher} = SlackCoder.Github.Supervisor.start_watcher(pr)
                 %PR{ pr | watcher: watcher}
               pr ->
                 pr
             end
    {:noreply, {repo, prs}}
  end

  def handle_info(:update_prs, {repo, existing_prs}) do
    pulls(repo, existing_prs)
    # State doesn't change until :pr_response message is received
    {:noreply, {repo, existing_prs}}
  end

end
