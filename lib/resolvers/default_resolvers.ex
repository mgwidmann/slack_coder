defmodule SlackCoder.Resolvers.DefaultResolvers do
  defmacro as(field) when is_atom(field) do
    IO.inspect field
    quote do
      fn
        _, %{source: source} when is_map(source) -> {:ok, Map.get(source, unquote(field))}
        _, _ -> nil
      end
    end
  end

  defmacro as(function) do
    quote do
      fn
        _, %{source: source} when is_map(source) -> {:ok, unquote(function).(source)}
        _, _ -> nil
      end
    end
  end

  # def slack_users() do
  #   batch({__MODULE__, :perform_batch, meta}, id, fn results ->
  #     results
  #     |> Map.get(id)
  #     |> callback.()
  #   end)
  # end
end
