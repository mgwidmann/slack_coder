defmodule SlackCoder.Models.StalePR do
  use Ecto.Model

  schema "stale_prs" do
    field :pr, :string
    field :backoff, :integer

    timestamps
  end

  @required_fields ~w(pr backoff)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    # |> unique_constraint(:status_id)
  end

end
