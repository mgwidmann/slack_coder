defmodule SlackCoder.Models.Types.Boolean do
  @behaviour Ecto.Type
  def type(), do: :boolean
  def cast(val), do: {:ok, value_to_boolean(val)}
  def load(val), do: {:ok, value_to_boolean(val)}
  def dump(val), do: {:ok, value_to_boolean(val)}

  def value_to_boolean(on) when on in ["on", "yes", "1", "y"], do: true
  def value_to_boolean(off) when off in ["off", "no", "0", "n"], do: false
  def value_to_boolean(bool) when bool in [true, false], do: bool
  def value_to_boolean(_), do: nil
end
