defmodule SlackCoder.Models.User.Config do
  use SlackCoder.Web, :model

  embedded_schema do
    for {config, value} <- SlackCoder.Users.Help.default_config do
      field String.to_atom(config), Boolean, default: value
    end
  end

  @required_fields ~w()
  @optional_fields SlackCoder.Users.Help.default_config_keys

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> strings_to_bools
  end

  defp strings_to_bools(changeset) do
    Enum.reduce @optional_fields, changeset, fn(field, cs)->
      put_change(cs, field, true)
    end
  end
end
