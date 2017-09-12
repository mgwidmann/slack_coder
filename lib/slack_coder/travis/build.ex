defmodule SlackCoder.Travis.Build do
  use HTTPoison.Base

  @keys ~w(id repository_id result)a
  defstruct @keys

  def new(build) do
    __MODULE__
    |> struct!(build |> Keyword.take(@keys))
    |> migrate_result()
  end

  defp migrate_result(%__MODULE__{result: 0} = build), do: Map.put(build, :result, :success)
  defp migrate_result(%__MODULE__{result: 1} = build), do: Map.put(build, :result, :failure)
  defp migrate_result(%__MODULE__{result: nil} = build), do: Map.put(build, :result, :error)
  defp migrate_result(%__MODULE__{result: _} = build), do: Map.put(build, :result, :unknown)

  defp process_url(url) do
    "https://api.travis-ci.com" <> url
  end

  @data_key "matrix"
  defp process_response_body(body) when is_binary(body) do
    body
    |> Poison.decode!()
    |> Map.take([@data_key])
    |> Map.get(@data_key)
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
