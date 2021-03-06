defmodule SlackCoder.BuildSystem.CircleCI.Build do
  use HTTPoison.Base
  require Logger
  alias SlackCoder.BuildSystem.Build

  def new(build, id) do
    %Build{id: id, result: result(build["status"]), url: build["output_url"]}
  end

  defp result("success"), do: :success
  defp result("failed"), do: :failure
  defp result(_), do: :unknown

  defp process_url("/" <> url), do: process_url(url)
  defp process_url(url) do
    "https://circleci.com/api/v1.1/#{url}?circle-token=#{Application.get_env(:slack_coder, :circle_ci_token)}"
  end

  defp process_response_body(body) when is_binary(body) do
    body
    |> Poison.decode!()
    |> handle_body()
  end

  def handle_body(%{"build_num" => build_num, "steps" => steps}) do
    steps
    |> Enum.flat_map(&(&1["actions"]))
    |> Enum.filter(&(&1["type"] == "test"))
    |> Enum.map(&__MODULE__.new(&1, build_num))
  end
  def handle_body(body) do
    Logger.warn "Received unexpected response from CircleCI: \n#{inspect body}"
    []
  end

  defp process_request_headers(headers) do
    [{"Accept", "application/json"} | headers]
  end
end