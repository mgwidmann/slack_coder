defmodule SlackCoder.BuildSystem do
  @moduledoc """
  """
  import StubAlias
  stub_alias SlackCoder.Travis
  alias SlackCoder.Travis.Build

  def failed_jobs(pr) do
    %{"build_id" => build_id} = Regex.named_captures(~r/(?<build_id>\d+)/, pr.build_url)
    Travis.build_info(pr.owner, pr.repo, build_id)
    |> Enum.filter(&match?(%Build{result: :failure}, &1))
    |> Enum.map(fn build ->
      Travis.job_log(build)
    end)
  end
end
