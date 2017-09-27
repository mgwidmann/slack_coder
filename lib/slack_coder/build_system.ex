defmodule SlackCoder.BuildSystem do
  @moduledoc """
  """
  import StubAlias
  stub_alias SlackCoder.BuildSystem.Travis
  stub_alias SlackCoder.BuildSystem.CircleCI
  stub_alias SlackCoder.BuildSystem.Semaphore
  alias SlackCoder.Models.RandomFailure.FailureLog
  alias SlackCoder.Repo
  import Ecto.Query
  require Logger

  defmodule Build do
    defstruct [:id, :repository_id, :result]
  end
  defmodule Job do
    defstruct [:id, :system, :tests, :failure_log_id]
    defmodule Test do
      defstruct [:type, :seed, :files]
    end
  end

  def failed_jobs(pr) do
    case build_id(pr) do
      {module, build_id} when not is_nil(build_id) ->
        module.build_info(pr.owner, pr.repo, build_id)
        |> Enum.filter(&match?(%Build{result: :failure}, &1))
        |> Enum.reject(&match?(%Build{id: nil}, &1))
        |> Enum.map(&(module.job_log(&1, pr)))
        |> Enum.filter(&(&1))
        |> Enum.map(&(Map.put(&1, :system, system_for_module(module))))
      other ->
        if supported?(pr) do
          Logger.warn [IO.ANSI.green, "[", inspect(__MODULE__), "] ", IO.ANSI.default_color, "Unable to extract build_url: #{inspect other, pretty: true}"]
        end
        []
    end
  end

  def record_failure_log(%SlackCoder.BuildSystem.Job{id: id, tests: tests} = job, log, pr) when is_integer(id) and length(tests) > 0 do
    ids_to_delete = for id <- FailureLog.by_pr(pr) |> FailureLog.with_external_id(id) |> select([q], q.id) |> Repo.all, Repo.one(FailureLog.without_random_failure(id)) != true, do: id
    Repo.delete_all(from(f in FailureLog, where: f.id in ^ids_to_delete)) # Clean up old logs
    %FailureLog{id: id} = Repo.insert!(FailureLog.changeset(%FailureLog{}, %{pr_id: pr.id, log: log, external_id: id, sha: pr.sha}))
    %{job | failure_log_id: id}
  end
  def record_failure_log(_job, _log, _pr), do: nil

  def supported?(pr) do
    case build_id(pr) do
      {_module, _build_id} -> true
      _                    -> false
    end
  end

  defp system_for_module(Travis), do: :travis
  defp system_for_module(CircleCI), do: :circleci
  defp system_for_module(Semaphore), do: :semaphore

  defp build_regex(pr) do
    [
      {Travis, ~r/https:\/\/travis-ci\.com\/#{pr.owner}\/#{pr.repo}\/builds\/(?<build_id>\d+)/},
      {Travis, ~r/https:\/\/magnum\.travis-ci\.com\/#{pr.owner}\/#{pr.repo}\/builds\/(?<build_id>\d+)/},
      # {CircleCI, ~r/https:\/\/circleci\.com\/gh\/#{pr.owner}\/#{pr.repo}\/(?<build_id>\d+)/},
      # {Semaphore, ~r/https:\/\/semaphoreci\.com\/#{pr.owner}\/#{pr.repo}\/branches\/#{pr.branch}\/builds\/(?<build_id>\d+)/}
    ]
  end

  defp build_id(pr) do
    for {module, regex} <- build_regex(pr) do
      {module, Regex.named_captures(regex, pr.build_url)}
    end
    |> Enum.reject(&match?({_, nil}, &1))
    |> case do
      [{module, %{"build_id" => build_id}}] when is_binary(build_id) ->
        {module, build_id}
      _ -> pr
    end
  end

  def counts(%Job.Test{} = test), do: counts([test])
  def counts([%Job.Test{} | _] = tests) do
    Enum.reduce(tests, %{}, fn %Job.Test{type: type}, map ->
      Map.put(map, type, (Map.get(map, type) || 0) + 1)
    end)
  end

  def counts([]), do: Map.new

  def counts([%Job{} | _] = jobs) do
    jobs
    |> Enum.map(&(&1.tests))
    |> List.flatten()
    |> counts()
  end
end

defimpl String.Chars, for: SlackCoder.BuildSystem.Job do
  def to_string(%SlackCoder.BuildSystem.Job{tests: tests}), do: Enum.join(tests, "\n") |> String.trim()
end

defimpl String.Chars, for: SlackCoder.BuildSystem.Job.Test do
  def to_string(%SlackCoder.BuildSystem.Job.Test{type: :rspec, seed: seed, files: [_|_] = files}) do
    """
    bundle exec rspec#{executable_line(files)} --seed #{seed}
    """ |> String.trim()
  end
  def to_string(%SlackCoder.BuildSystem.Job.Test{type: :cucumber, files: [_|_] = files}) do
    """
    bundle exec cucumber#{executable_line(files)}
    """ |> String.trim()
  end
  def to_string(_), do: nil

  defp executable_line(list, acc \\ "")
  defp executable_line([], acc), do: acc
  defp executable_line([{file, line, _desc} | rest], acc), do: executable_line(rest, acc <> " " <> file <> ":" <> line)
end
