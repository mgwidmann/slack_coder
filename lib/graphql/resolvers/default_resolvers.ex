defmodule SlackCoder.GraphQL.Resolvers.DefaultResolvers do
  defmacro as(field) when is_atom(field) do
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

  def force_boolean(field) do
    fn _, %{source: data} -> {:ok, !!Map.get(data, field)} end
  end

  defmacro timestamps(names \\ [], resolve \\ []) do
    inserted_at = Keyword.get(names, :inserted_at, :inserted_at)
    resolve_inserted_at = Keyword.get(resolve, :inserted_at, :inserted_at)
    updated_at = Keyword.get(names, :updated_at, :updated_at)
    resolve_updated_at = Keyword.get(resolve, :updated_at, :updated_at)
    quote do
      @desc "Timestamp indicating when this data was first added to the database."
      field unquote(inserted_at), :datetime, resolve: as(unquote(resolve_inserted_at))
      @desc "Timestamp indicating when this data was last saved to the database."
      field unquote(updated_at), :datetime, resolve: as(unquote(resolve_updated_at))
    end
  end
end
