defmodule SlackCoder.Github.EventProcessor do
  require Logger
  alias SlackCoder.Github.Watchers.PullRequest, as: PullRequest
  alias SlackCoder.Models.PR

  def process(:push, params) do
    # Logger.info "EventProcessor received push event: #{inspect params, pretty: true}"
  end

  def process(:issue_comment, %{"issue" => %{"number" => pr}}= params) do
    Logger.info "EventProcessor received issue_comment event: #{inspect params, pretty: true}"

    %PR{number: pr}
    |> SlackCoder.Github.Supervisor.find_watcher()
    |> PullRequest.unstale()
  end

  def process(:commit_comment, params) do
    Logger.info "EventProcessor received commit_comment event: #{inspect params, pretty: true}"

    %PR{number: pr_number(params)}
    |> SlackCoder.Github.Supervisor.find_watcher()
    |> PullRequest.unstale()
  end
  def process(:issues, params) do
    # Logger.info "EventProcessor received issues event: #{inspect params, pretty: true}"
  end

  def process(:pull_request, %{"action" => opened, "number" => pr} = params) when opened in ["opened", "reopened"] do
    Logger.info "EventProcessor received #{opened} event: #{inspect params, pretty: true}"

    # login = params["pull_request"]["user"]["login"]
    %PR{number: pr}
    |> SlackCoder.Github.Supervisor.start_watcher()
    |> PullRequest.update(params["pull_request"])
  end

  def process(:pull_request, %{"action" => "closed", "number" => number} = params) do
    IO.puts "EventProcessor received closed event: #{inspect params, pretty: true}"

    %PR{number: number}
    |> SlackCoder.Github.Supervisor.find_watcher()
    |> PullRequest.update_sync(params["pull_request"])
    |> SlackCoder.Github.Supervisor.stop_watcher()
  end

  def process(:pull_request, %{"action" => "synchronize", "number" => pr, "commits" => commits} = params) do
    commit = commits |> List.last()

    Logger.info "EventProcessor received pull_request synchronize event: #{inspect params, pretty: true}"

    %PR{number: pr}
    |> SlackCoder.Github.Supervisor.find_or_start_watcher()
    |> PullRequest.update(params["pull_request"], commit)
  end

  def process(:pull_request, %{"action" => other} = params) do
    # Logger.warn "EventProcessor received #{other} event: #{inspect params, pretty: true}"
  end

  def process(:pull_request_review_comment, params) do
    Logger.info "EventProcessor received pull_request_review_comment event: #{inspect params, pretty: true}"

    %PR{number: pr_number(params)}
    |> SlackCoder.Github.Supervisor.find_watcher()
    |> PullRequest.unstale()
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

  def pr_number(%{"comment" => %{"pull_request_url" => url}}) do
    # Github does not deliver the PR number as an individual field...
    case Regex.scan(~r/\/pulls\/(\d+)$/, url || "") do
      [[_, pr]] -> pr
      _ -> nil
    end
  end

  def pr_number(_), do: nil
end
