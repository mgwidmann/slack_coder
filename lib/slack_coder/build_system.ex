defmodule SlackCoder.BuildSystem do
  @moduledoc """
  """
  import StubAlias
  stub_alias SlackCoder.BuildSystem.Travis
  stub_alias SlackCoder.BuildSystem.CircleCI
  stub_alias SlackCoder.BuildSystem.Semaphore
  alias SlackCoder.Models.RandomFailure.FailureLog
  alias SlackCoder.Repo
  require Logger

  defmodule Build do
    defstruct [:id, :repository_id, :result]
  end
  defmodule Job do
    defstruct [:id, :system, :rspec_seed, :rspec, :cucumber_seed, :cucumber, :failure_log_id]
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
        Logger.warn [IO.ANSI.green, "[", inspect(__MODULE__), "] ", IO.ANSI.default_color, "Unable to extract build_url: #{inspect other, pretty: true}"]
        []
    end
  end

  def record_failure_log(%SlackCoder.BuildSystem.Job{id: id, rspec: rspec, cucumber: cucumber} = job, log, pr) when is_binary(id) and (length(rspec) > 0 or length(cucumber) > 0) do
    Repo.delete_all(FailureLog.by_pr(pr) |> FailureLog.with_external_id(id)) # Clean up old logs
    %FailureLog{id: id} = Repo.insert!(FailureLog.changeset(%FailureLog{}, %{pr_id: pr.id, log: log, external_id: id}))
    %{job | failure_log_id: id}
  end
  def record_failure_log(job, _log, _pr), do: job

  defp system_for_module(Travis), do: :travis
  defp system_for_module(CircleCI), do: :circleci
  defp system_for_module(Semaphore), do: :semaphore

  defp build_regex(pr) do
    [
      {Travis, ~r/https:\/\/travis-ci\.com\/#{pr.owner}\/#{pr.repo}\/builds\/(?<build_id>\d+)/},
      {Travis, ~r/https:\/\/magnum\.travis-ci\.com\/#{pr.owner}\/#{pr.repo}\/builds\/(?<build_id>\d+)/},
      {CircleCI, ~r/https:\/\/circleci\.com\/gh\/#{pr.owner}\/#{pr.repo}\/(?<build_id>\d+)/},
      {Semaphore, ~r/https:\/\/semaphoreci\.com\/#{pr.owner}\/#{pr.repo}\/branches\/#{pr.branch}\/builds\/(?<build_id>\d+)/}
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
end

defimpl String.Chars, for: SlackCoder.BuildSystem.Job do
  def to_string(%SlackCoder.BuildSystem.Job{rspec_seed: rspec_seed, rspec: rspec, cucumber_seed: cucumber_seed, cucumber: cucumber}) do
    if rspec != [] do
      """
      bundle exec rspec#{executable_line(rspec)} --seed #{rspec_seed}
      """
    else
      ""
    end <> (if cucumber != [] do
      """
      bundle exec cucumber#{executable_line(cucumber)} --order random:#{cucumber_seed}
      """
    else
      ""
    end) |> String.trim_trailing()
  end

  def executable_line(list, acc \\ "")
  def executable_line([], acc), do: acc
  def executable_line([{file, line, _desc} | rest], acc), do: executable_line(rest, acc <> " " <> file <> ":" <> line)
end
