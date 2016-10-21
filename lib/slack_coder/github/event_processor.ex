defmodule SlackCoder.Github.EventProcessor do
  require Logger
  alias SlackCoder.Github.Watchers.PullRequest, as: PullRequest
  alias SlackCoder.Models.PR

  def process(:push, params) do
    Logger.info "EventProcessor received push event: #{inspect params, pretty: true}"
  end
  def process(:issue_comment, params) do
    Logger.info "EventProcessor received issue_comment event: #{inspect params, pretty: true}"
  end
  def process(:commit_comment, params) do
    Logger.info "EventProcessor received commit_comment event: #{inspect params, pretty: true}"
  end
  def process(:issues, params) do
    Logger.info "EventProcessor received issues event: #{inspect params, pretty: true}"
  end
  def process(:pull_request, %{"action" => opened, "number" => pr} = params) when opened in ["opened", "reopened"] do
    %PR{number: pr, webhook: true}
    |> SlackCoder.Github.Supervisor.start_watcher()
    |> PullRequest.update(params["pull_request"])
  end
  def process(:pull_request, %{"action" => "closed", "number" => pr} = params) do
    %PR{number: pr, webhook: true}
    |> SlackCoder.Github.Supervisor.stop_watcher()
    |> PullRequest.update(params["pull_request"])
  end
  def process(:pull_request, %{"action" => "synchronize", "number" => pr, "commits" => commits} = params) do
    commit = commits |> List.last()

    Logger.info "EventProcessor received pull_request synchronize event: #{inspect params, pretty: true}"

    %PR{number: pr, webhook: true}
    |> SlackCoder.Github.Supervisor.find_watcher()
    |> PullRequest.update(params["pull_request"])
    # |> PullRequest.update_commit(commit)
  end
  def process(:pull_request, %{"action" => _other}) do
    # Don't care
  end
  def process(:pull_request_review_comment, params) do
    # %PR{number: pr, webhook: true}
    # |> SlackCoder.Github.Supervisor.find_watcher()
    # |> PullRequest.unstale()

    Logger.info "EventProcessor received pull_request_review_comment event: #{inspect params, pretty: true}"
  end
  def process(:status, params) do

    Logger.info "EventProcessor received status event: #{inspect params, pretty: true}"
  end
  def process(:ping, params) do
    Logger.info "EventProcessor received ping event: #{inspect params, pretty: true}"
  end
  def process(unknown_event, params) do
    Logger.warn "EventProcessor received unknown event #{inspect unknown_event} with params #{inspect params, pretty: true}"
  end
end
