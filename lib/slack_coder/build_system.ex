defmodule SlackCoder.BuildSystem do
  @moduledoc """
  """
  import StubAlias
  stub_alias SlackCoder.BuildSystem.Travis
  stub_alias SlackCoder.BuildSystem.CircleCI
  stub_alias SlackCoder.BuildSystem.Semaphore
  require Logger

  def failed_jobs(pr) do
    case build_id(pr) do
      {module, build_id} when not is_nil(build_id) ->
        module.build_info(pr.owner, pr.repo, build_id)
        |> Enum.filter(&match?(%{result: :failure}, &1))
        |> Enum.map(&module.job_log(&1))
      other ->
        Logger.warn [IO.ANSI.green, "[", inspect(__MODULE__), "] ", IO.ANSI.default_color, "Unable to extract build_url: #{inspect other}"]
        []
    end
  end

  defp build_regex(pr) do
    [
      {Travis, ~r/https:\/\/travis-ci\.com\/#{pr.owner}\/#{pr.repo}\/builds\/(?<build_id>\d+)/},
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

  defmodule Build do
    defstruct [:id, :repository_id, :result]
  end
  defmodule Job do
    defstruct [:rspec_seed, :rspec, :cucumber_seed, :cucumber]
  end
end

defimpl String.Chars, for: SlackCoder.BuildSystem.Job do
  def to_string(%SlackCoder.BuildSystem.Job{rspec_seed: rspec_seed, rspec: rspec, cucumber_seed: cucumber_seed, cucumber: cucumber}) do
    if rspec != [] do
      """
      bundle exec rspec #{rspec |> Enum.map(&(Tuple.to_list(&1) |> Enum.join(":"))) |> Enum.join(" ")} --seed #{rspec_seed}
      """
    else
      ""
    end <> (if cucumber != [] do
      """
      bundle exec cucumber #{cucumber |> Enum.map(&(Tuple.to_list(&1) |> Enum.join(":"))) |> Enum.join(" ")} --order random:#{cucumber_seed}
      """
    else
      ""
    end) |> String.trim_trailing()
  end
end
