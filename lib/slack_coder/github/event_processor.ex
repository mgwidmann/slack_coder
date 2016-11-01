defmodule SlackCoder.Github.EventProcessor do
  require Logger
  alias SlackCoder.Github.Watchers.PullRequest, as: PullRequest
  alias SlackCoder.Github.Watchers.Supervisor, as: Github
  alias SlackCoder.Models.PR
  alias SlackCoder.Github.ShaMapper

  @doc """
  Processes a Github event with the given parameters. Handles routing to the proper PR process
  to update depending upon what occurred. Occurs asynchronously by starting a new process to handle
  the request as to not block the caller.
  """
  def process_async(event, params) do
    Task.start __MODULE__, :process, [event, params]
  end

  @doc """
  Processes a Github event synchronously. See `proccess_async/2` for more info.
  """
  def process(event, parameters)
  # Would like to be able to reset a PR here but there doesn't seem to be enough info
  # to determine what PR the push belonged to without querying Github's API.
  def process(:push, %{"before" => old_sha, "after" => new_sha} = params) do
    Logger.debug "EventProcessor received push event"
    ShaMapper.update(old_sha, new_sha)
  end

  # A user has made a comment on the PR itself (not related to any code).
  def process(:issue_comment, %{"issue" => %{"number" => pr}}= params) do
    Logger.debug "EventProcessor received issue_comment event"

    %PR{number: pr}
    |> Github.find_watcher()
    |> PullRequest.unstale()
  end

  # A user has made a comment on code belonging to a PR. When a user makes a comment on a commit not related to a PR,
  # the `find_watcher/1` call will return `nil` and subsequent function calls will just do nothing.
  def process(:commit_comment, params) do
    Logger.debug "EventProcessor received commit_comment event"

    %PR{number: pr_number(params)}
    |> Github.find_watcher()
    |> PullRequest.unstale()
  end

  # Issues have been changed/created. Ignoring this.
  def process(:issues, _params) do
    # Logger.debug "EventProcessor received issues event: #{inspect params, pretty: true}"
  end

  # A pull request has been opened or reopened. Need to start the watcher synchronously, then send it data
  # to update it to the most recent PR information.
  def process(:pull_request, %{"action" => opened, "number" => number, "pull_request" => pull_request} = params) when opened in ["opened", "reopened"] do
    Logger.debug "EventProcessor received #{opened} event"

    # login = params["pull_request"]["user"]["login"]
    %PR{number: number, sha: pull_request["head"]["sha"]}
    |> Github.start_watcher()
    |> PullRequest.update(pull_request)
  end

  # Handles a pull request being closed. Need to find the watcher, synchronously update it so the information is persisted
  # and then stop the watcher. This will ensure that either the `closed_at` or `merged_at` fields are set and when the
  # system is restarted it will not start a watcher for that PR anymore.
  def process(:pull_request, %{"action" => "closed", "number" => number} = params) do
    Logger.debug "EventProcessor received closed event"

    %PR{number: number}
    |> Github.find_watcher()
    |> PullRequest.update_sync(params["pull_request"])
    |> Github.stop_watcher()
  end

  # When a pull request information is changed, this is called in order to update it asynchronously.
  def process(:pull_request, %{"action" => "synchronize", "number" => pr, "before" => old_sha, "after" => new_sha} = params) do
    ShaMapper.update(old_sha, new_sha)

    Logger.debug "EventProcessor received pull_request synchronize event"

    %PR{number: pr}
    |> Github.find_or_start_watcher()
    |> PullRequest.update(params["pull_request"])
  end

  def process(:pull_request, %{"action" => _other} = _params) do
    # Ignore
  end

  # A comment was added to a pull request
  def process(:pull_request_review_comment, params) do
    Logger.debug "EventProcessor received pull_request_review_comment event"

    %PR{number: pr_number(params)}
    |> Github.find_watcher()
    |> PullRequest.unstale()
  end

  # Build has changed status for a CI system
  def process(:status, %{"context" => ci_system, "state" => state, "target_url" => url, "sha" => sha} = params) when ci_system in ["continuous-integration/travis-ci/pr", "semaphoreci"] do
    Logger.debug "EventProcessor received build status event of state #{state}"
    ShaMapper.find(sha)
    |> PullRequest.status(:build, sha, url, state)
  end

  # Build has change status for an Analysis system
  def process(:status, %{"context" => "codeclimate", "state" => state, "target_url" => url, "sha" => sha} = params) do
    Logger.debug "EventProcessor received analysis status event of state #{state}"

    ShaMapper.find(sha)
    |> PullRequest.status(:analysis, sha, url, state)
  end

  # Nothing to do for pings, already responded with a 200 so just exit
  def process(:ping, _params) do
    # Ignore
  end

  def process(unknown_event, params) do
    Logger.warn "EventProcessor received unknown event #{inspect unknown_event} with params"
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
