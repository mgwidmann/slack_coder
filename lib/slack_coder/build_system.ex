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
  defmodule File do
    defstruct [:id, :type, :seed, :file, :system, :failure_log_id]
  end

  def failed_jobs(pr) do
    case build_id(pr) do
      {module, build_id} when not is_nil(build_id) ->
        module.build_info(pr.owner, pr.repo, build_id)
        |> Enum.filter(&match?(%Build{result: :failure}, &1))
        |> Enum.reject(&match?(%Build{id: nil}, &1))
        |> Enum.map(&(module.job_log(&1, pr)))
        |> Enum.filter(&(&1))
        |> Enum.map(fn f -> Enum.map(f, &Map.put(&1, :system, system_for_module(module))) end)
        |> List.flatten()
      other ->
        if supported?(pr) do
          Logger.warn [IO.ANSI.green, "[", inspect(__MODULE__), "] ", IO.ANSI.default_color, "Unable to extract build_url: #{inspect other, pretty: true}"]
        end
        []
    end
  end

  def record_failure_log(%File{} = file, log, pr), do: record_failure_log([file], log, pr) |> hd()
  def record_failure_log(files, log, pr) when is_list(files) do
    for %File{id: id} = file <- files do
      case Repo.one(FailureLog.with_external_ids(id) |> select([f], f.id)) do
        nil ->
          %FailureLog{id: id} = Repo.insert!(FailureLog.changeset(%FailureLog{}, %{pr_id: pr.id, log: log, external_id: id, sha: pr.sha}))
          %{file | failure_log_id: id}
        id ->
          %{file | failure_log_id: id}
      end
    end
  end

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

  def counts([]), do: Map.new

  def counts([%File{} | _] = files) do
    files
    |> List.flatten()
    |> Enum.group_by(&(&1.type))
    |> Enum.map(fn {type, list} -> {type, length(list)} end)
    |> Enum.into(%{})
  end
end
