defmodule SlackCoder.Github.EventProcessor do
  require Logger
  alias SlackCoder.Github.Watchers.PullRequest, as: PullRequest
  alias SlackCoder.Github.Watchers.Supervisor, as: Github
  alias SlackCoder.Github.Watchers.MergeConflict
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
  def process(event, parameters) do
    if do_process(event, parameters) in [nil, false] do
      Logger.warn """
      Processing event #{event} returned `nil` or `false` with parameters:
      #{inspect parameters, pretty: true}
      """
      false
    else
      true
    end
  end

  # Would like to be able to reset a PR here but there doesn't seem to be enough info
  # to determine what PR the push belonged to without querying Github's API.
  defp do_process(:push, %{"before" => old_sha, "after" => "0000000000000000000000000000000000000000", "deleted" => true}) do
    ShaMapper.remove(old_sha)
    :ok # Even if it isnt found this is ok
  end
  defp do_process(:push, %{"before" => old_sha, "after" => new_sha}) do
    ShaMapper.update(old_sha, new_sha)

    ShaMapper.find(new_sha)
    |> PullRequest.fetch()
    |> MergeConflict.queue()

    :ok # Pushes can happen even if they're not related to a PR
  end

  # A user has made a comment on the PR itself (not related to any code).
  defp do_process(:issue_comment, %{"issue" => %{"number" => _pr}} = _pull_request) do
    :ok
    # TODO: Get working again
    # owner = pull_request["base"]["repo"]["owner"]["login"]
    # repo = pull_request["base"]["repo"]["name"]
    # %PR{owner: owner, repo: repo, number: pr}
    # |> Github.find_watcher()
    # |> PullRequest.unstale()
  end

  # A user has made a comment on code belonging to a PR. When a user makes a comment on a commit not related to a PR,
  # the `find_watcher/1` call will return `nil` and subsequent function calls will just do nothing.
  defp do_process(:commit_comment, _params) do
    :ok
    # TODO: Get working again
    # owner = pull_request["base"]["repo"]["owner"]["login"]
    # repo = pull_request["base"]["repo"]["name"]
    # %PR{owner: owner, repo: repo, number: pr_number(params)}
    # |> Github.find_watcher()
    # |> PullRequest.unstale()
  end

  # Issues have been changed/created. Ignoring this.
  defp do_process(:issues, _params) do
    :ok
  end

  # A pull request has been opened or reopened. Need to start the watcher synchronously, then send it data
  # to update it to the most recent PR information.
  defp do_process(:pull_request, %{"action" => opened, "number" => number, "pull_request" => pull_request}) when opened in ["opened", "reopened"] do
    # Handling a modified version of the pull_request object which comes from SlackCoder.Github
    owner = pull_request["base"]["repo"]["owner"]["login"] || pull_request[:owner]
    repo = pull_request["base"]["repo"]["name"] || pull_request[:repo]
    pid = %PR{owner: owner, repo: repo, number: number, sha: pull_request["head"]["sha"] || pull_request[:sha]}
          |> Github.start_watcher()
    pid
    |> PullRequest.fetch()
    |> MergeConflict.queue()

    pid
    |> PullRequest.update(pull_request)
  end

  # Handles a pull request being closed. Need to find the watcher, synchronously update it so the information is persisted
  # and then stop the watcher. This will ensure that either the `closed_at` or `merged_at` fields are set and when the
  # system is restarted it will not start a watcher for that PR anymore.
  defp do_process(:pull_request, %{"action" => "closed", "number" => number} = params) do
    owner = params["pull_request"]["base"]["repo"]["owner"]["login"]
    repo = params["pull_request"]["base"]["repo"]["name"]

    %PR{owner: owner, repo: repo, number: number}
    |> Github.find_watcher()
    |> PullRequest.update_sync(params["pull_request"])
    |> Github.stop_watcher()
  end

  # When a pull request information is changed, this is called in order to update it asynchronously.
  @synchronize ~w(edited synchronize)
  defp do_process(:pull_request, %{"action" => action, "before" => old_sha, "after" => new_sha} = params) when action in @synchronize do
    ShaMapper.update(old_sha, new_sha)

    Logger.debug "EventProcessor received pull_request synchronize event"
    do_process(:pull_request, params |> Map.drop(~w(before after)))
  end

  defp do_process(:pull_request, %{"action" => action, "number" => pr} = params) when action in @synchronize do
    owner = params["pull_request"]["base"]["repo"]["owner"]["login"]
    repo = params["pull_request"]["base"]["repo"]["name"]
    pid = %PR{owner: owner, repo: repo, number: pr}
          |> Github.find_or_start_watcher()
    pid
    |> PullRequest.fetch()
    |> MergeConflict.queue()

    pid
    |> PullRequest.update(params["pull_request"])
  end

  # TODO: Implement `review_requested`
  @unprocessed ~w(unlabeled labeled assigned unassigned review_requested)
  defp do_process(:pull_request, %{"action" => action}) when action in @unprocessed, do: :ok

  defp do_process(:pull_request, %{"action" => other} = _params) do
    Logger.warn "Ignoring :pull_request event #{other}"
    false
  end

  # A comment was added to a pull request
  defp do_process(:pull_request_review_comment, params) do
    %PR{number: pr_number(params)}
    |> Github.find_watcher()
    |> PullRequest.unstale()
  end

  # Build has changed status for a CI system
  @ci_systems ~w(default ci/circleci continuous-integration/travis-ci/pr continuous-integration/travis-ci/push semaphoreci)
  defp do_process(:status, %{"context" => ci_system, "state" => state, "target_url" => url, "sha" => sha}) when ci_system in @ci_systems do
    ShaMapper.find(sha)
    |> PullRequest.status(:build, sha, url, state)
  end

  @ignored_contexts ~w(ci/bitrise codeclimate/diff-coverage codeclimate/total-coverage codecov/project codecov/patch)
  for context <- @ignored_contexts do
    defp do_process(:status, %{"context" => unquote(context) <> _}) do
      # Ignore
      :ok
    end
  end

  # Build has change status for an Analysis system
  @analysis_systems ~w(codeclimate)
  defp do_process(:status, %{"context" => analysis_system, "state" => state, "target_url" => url, "sha" => sha}) when analysis_system in @analysis_systems do
    ShaMapper.find(sha)
    |> PullRequest.status(:analysis, sha, url, state)
  end

  # Nothing to do for pings, already responded with a 200 so just exit
  defp do_process(:ping, _params) do
    # Ignore
    :ok
  end

  defp do_process(:project_card, _params) do
    # Ignore
    :ok
  end

  defp do_process(:pull_request_review, _params) do
    # Ignore
    :ok
  end

  defp do_process(:create, _params) do
    # Ignore
    :ok
  end

  defp do_process(:release, _params) do
    # Ignore
    :ok
  end

  defp do_process(:delete, _params) do
    # Ignore
    :ok
  end

  defp do_process(:team, _params) do
    # Ignore
    :ok
  end

  defp do_process(:team_add, _params) do
    # Ignore
    :ok
  end

  defp do_process(:fork, _params) do
    # Ignore
    :ok
  end

  defp do_process(:milestone, _params) do
    # Ignore
  end

  defp do_process(:organization, _params) do
    # Ignore
    :ok
  end

  defp do_process(:membership, _params) do
    # Ignore
    :ok
  end

  defp do_process(unknown_event, params) do
    Logger.warn "EventProcessor received unknown event #{inspect unknown_event} with params #{inspect params, pretty: true}"
  end

  def pr_number(%{"pull_request" => %{"number" => number}}) do
    number
  end

  def pr_number(_), do: nil
end
