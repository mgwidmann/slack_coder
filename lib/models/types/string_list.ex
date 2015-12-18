defmodule SlackCoder.Models.Types.StringList do
  @behaviour Ecto.Type

  def type(), do: :string

  def cast(string) when is_binary(string) do
    case Poison.decode(string) do
      {:ok, list} -> {:ok, Enum.filter(list, &(&1))}
      other -> other
    end
  end
  def cast(list) when is_list(list) do
    {:ok, Enum.filter(list, &(&1))}
  end

  def load(string), do: Poison.decode(string)

  def dump(string) when is_binary(string), do: Poison.decode(string)
  def dump(list) when is_list(list), do: Poison.encode(list)

end
