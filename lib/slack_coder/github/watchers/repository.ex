defmodule SlackCoder.Github.Watchers.Repository do
  use GenServer
  require Logger
  import SlackCoder.Github.Watchers.Repository.Helper


  @poll_minutes 1
  @poll_interval 60_000 * @poll_minutes # 5 minutes

  def start_link(repo) do
    GenServer.start_link __MODULE__, repo
  end

  def init(repo) do
    repo_config = Application.get_env(:slack_coder, :repos, [])[repo]
    if repo_config[:webhook] do
      Logger.info "Setting webhook for #{repo_config[:owner]}/#{repo}"
      try do
        SlackCoder.Github.set_hook(repo_config[:owner], repo)
      rescue # Rate limiting from Github causes exceptions, until a better solution
        e -> # within Tentacat presents itself, just log the exception...
          Logger.error "Unable to set webhook: #{Exception.message(e)}\n#{Exception.format_stacktrace}"
      end
    end
    pulls(repo) # Async fetch
    :timer.send_interval @poll_interval, :update_prs
    {:ok, {repo, []}}
  end

  def handle_info({:pr_response, prs}, {repo, old_prs}) do
    prs = prs # new prs start watchers for each
          |> Stream.map(fn(pr)->
            SlackCoder.Github.Supervisor.start_watcher(pr)

            try do
              pr
              |> find_latest_comment_date
              |> build_changeset(pr)
              |> handle_closed_pr(old_prs)
              |> update_pr
            rescue
              e ->
                Logger.error "Unable to set webhook: #{Exception.message(e)}\n#{Exception.format_stacktrace}"
                pr
            end
          end)
          |> Enum.reject(fn(pr)->
            pr.closed_at || pr.merged_at
          end)

    {:noreply, {repo, prs}}
  end

  def handle_info(:update_prs, {repo, existing_prs}) do
    pulls(repo, existing_prs)
    # State doesn't change until :pr_response message is received
    {:noreply, {repo, existing_prs}}
  end

  def poll_minutes(), do: @poll_minutes

end
