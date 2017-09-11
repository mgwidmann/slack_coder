defmodule SlackCoder.Travis do
  alias SlackCoder.Travis.Build
  alias SlackCoder.Travis.Job
  require Logger

  def build_info(owner, repo, build) do
    "/repos/#{owner}/#{repo}/builds/#{build}"
    |> Build.get()
    |> case do
      {:ok, response} ->
        response
      {:error, problem} ->
        Logger.warn """
        #{__MODULE__} job build fetch failed

        #{inspect problem}
        """
        %{body: []} # Return nothing
    end
    |> Map.fetch!(:body)
  end

  def job_log(build) do
    "/jobs/#{build.id}/log"
    |> Job.get()
    |> case do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
        |> Job.filter_log()
        |> Job.new()
      # Cannot use follow_redirect: true, cause need to drop authorization header
      {:ok, %HTTPoison.Response{status_code: 307, headers: headers}} ->
        {"Location", redirect} = Enum.find(headers, &(match?({"Location", _}, &1)))
        HTTPoison.get(redirect)
        |> case do
          {:ok, response} -> response
          {:error, problem} ->
            Logger.warn """
            #{__MODULE__} job log fetch failed

            #{inspect problem}
            """
            %{body: ""}
        end
        |> Map.fetch!(:body)
        |> Job.filter_log()
        |> Job.new()
      {ok_or_error, response} when ok_or_error in [:ok, :error] ->
        Logger.warn """
        #{__MODULE__} job log fetch failed

        #{inspect response}
        """
        Job.new([])
    end
  end

end
