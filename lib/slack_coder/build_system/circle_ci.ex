defmodule SlackCoder.BuildSystem.CircleCI do
  alias SlackCoder.BuildSystem.LogParser
  alias SlackCoder.BuildSystem.CircleCI.Build
  require Logger
  import HTTPoison.Retry

  def build_info(owner, repo, build) do
    "/project/github/#{owner}/#{repo}/#{build}"
    |> Build.get()
    |> autoretry()
    |> handle_build_fetch()
  end

  defp handle_build_fetch({:ok, %HTTPoison.Response{status_code: 200, body: body}}) when is_list(body) do
    body
  end
  defp handle_build_fetch({ok_or_error, problem}) when ok_or_error in ~w(ok error)a do
    Logger.warn """
    #{__MODULE__} job build fetch failed

    #{inspect problem}
    """
    [] # Return nothing
  end

  def job_log(%SlackCoder.BuildSystem.Build{id: id, url: url}, pr) do
    HTTPoison.get(url)
    |> autoretry()
    |> handle_job_log()
    |> put_job_id(id)
    |> case do
      {job, body} ->
        job
        |> SlackCoder.BuildSystem.record_failure_log(body, pr)
      _ -> nil
    end
  end

  defp handle_job_log({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    body = body
           |> :zlib.gunzip()
           |> Poison.decode!()
           |> Enum.filter(&(&1["type"] == "out"))
           |> Enum.map(&(&1["message"]))
           |> Enum.join("\n")
    {LogParser.parse(body), body}
  end
  defp handle_job_log({ok_or_error, problem}) when ok_or_error in ~w(ok error)a do
    Logger.warn """
    #{__MODULE__} job log fetch failed

    #{inspect problem}
    """
    {nil, nil} # Return nothing
  end

  defp put_job_id({nil, _}, _id), do: nil
  defp put_job_id({files, body}, id), do: {Enum.map(files, &(Map.put(&1, :id, id))), body}
end
