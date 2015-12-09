defmodule SlackCoder.Models.User do
  use SlackCoder.Web, :model

  schema "users" do
    field :slack, :string
    field :github, :string
    field :config, :map

    timestamps
  end

  @required_fields ~w(slack github config)
  @optional_fields ~w()

  def by_slack(name) when is_binary(name) do
    from u in __MODULE__, where: u.slack == ^name
  end
  def by_slack(name), do: to_string(name) |> by_slack

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
