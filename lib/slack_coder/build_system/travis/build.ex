defmodule SlackCoder.BuildSystem.Travis.Build do
  use HTTPoison.Base
  require Logger
  alias SlackCoder.BuildSystem.Build

  @keys Map.keys(Build.__struct__)
  def new(build) do
    Build
    |> struct!(build |> Keyword.take(@keys))
    |> migrate_result()
  end

  defp migrate_result(%Build{result: 0} = build), do: Map.put(build, :result, :success)
  defp migrate_result(%Build{result: 1} = build), do: Map.put(build, :result, :failure)
  defp migrate_result(%Build{result: nil} = build), do: Map.put(build, :result, :error)
  defp migrate_result(%Build{result: _} = build), do: Map.put(build, :result, :unknown)

  defp process_url(url) do
    "https://api.travis-ci.com" <> url
  end

  @data_key "matrix"
  defp process_response_body(body) when is_binary(body) do
    decoded = Poison.decode!(body)
    unless @data_key in Map.keys(decoded) do
      Logger.warn ["[", IO.ANSI.green, inspect(__MODULE__), "] ", IO.ANSI.default_color, "Received unexpected response: ", inspect(decoded)]
    end
    Map.get(decoded, @data_key, [])
    |> Enum.map(fn build ->
      build
      |> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)
      |> __MODULE__.new()
    end)
  end

  defp process_request_headers(headers) do
    token = Application.get_env(:slack_coder, :travis_token)
    [{"Authorization", "token #{token}"} | headers]
  end
end
