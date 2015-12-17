defmodule SlackCoder.Models.Types.StringList do
  @behaviour Ecto.Type

  def type(), do: :string

  def cast(string) when is_binary(string), do: Poison.decode(string)
  def cast(list) when is_list(list), do: {:ok, list}

  def load(string), do: Poison.decode(string)

  def dump(string) when is_binary(string), do: Poison.decode(string)
  def dump(list) when is_list(list), do: Poison.encode(list)

end
