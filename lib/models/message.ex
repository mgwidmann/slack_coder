defmodule SlackCoder.Models.Message do
  use SlackCoder.Web, :model

  schema "messages" do
    field :slack, :string
    field :user, :string
    field :message, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:slack, :user, :message])
    |> validate_required([:slack, :user, :message])
  end
end
