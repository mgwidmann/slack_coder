defmodule SlackCoder.Travis do
  alias SlackCoder.Travis.Build
  alias SlackCoder.Travis.Job

  def build_info(owner, repo, build) do
    "/repos/#{owner}/#{repo}/builds/#{build}"
    |> Build.get!()
    |> Map.fetch!(:body)
  end

  def job_log(build) do
    "/jobs/#{build.id}/log"
    |> Job.get!()
    |> case do
      %HTTPoison.Response{status_code: 200, body: body} ->
        body
      # Cannot use follow_redirect: true, cause need to drop authorization header
      %HTTPoison.Response{status_code: 307, headers: headers} ->
        {"Location", redirect} = Enum.find(headers, &(match?({"Location", _}, &1)))
        HTTPoison.get!(redirect)
        |> Map.fetch!(:body)
        |> Job.filter_log()
        |> Job.new()
    end
  end

end
