defmodule SlackCoder.BuildSystem do
  @moduledoc """
  """
  import StubAlias
  stub_alias SlackCoder.Travis
  stub_alias SlackCoder.CircleCI
  require Logger

  def failed_jobs(pr) do
    case build_id(pr) do
      {module, build_id} when not is_nil(build_id) ->
        module.build_info(pr.owner, pr.repo, build_id)
        |> Enum.filter(&match?(%{result: :failure}, &1))
        |> Enum.map(fn build ->
          module.job_log(build)
        end)
      other ->
        Logger.warn [IO.ANSI.green, "[", inspect(__MODULE__), "] ", IO.ANSI.default_color, "Unable to extract build_url: #{inspect other}"]
    end
  end

  defp build_regex(pr) do
    [
      {Travis, ~r/https:\/\/travis-ci\.com\/#{pr.owner}\/#{pr.repo}\/builds\/(?<build_id>\d+)/},
      {CircleCI, ~r/https:\/\/circleci\.com\/gh\/#{pr.owner}\/#{pr.repo}\/(?<build_id>\d+)/}
    ]
  end

  defp build_id(pr) do
    for {module, regex} <- build_regex(pr) do
      {module, Regex.named_captures(regex, pr.build_url)}
    end
    |> Enum.reject(&match?({_, %{"build_id" => nil}}, &1))
    |> case do
      {module, %{"build_id" => build_id}} when not is_nil(build_id) ->
        {module, build_id}
    end
  end
end
