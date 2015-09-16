defmodule SlackCoder.Models.ReportedCommit do
  use Ecto.Model

  schema "reported_commits" do
    field :repo, :string
    field :sha, :string
    field :status_id, :integer
    field :status, :string
    field :github_user, :string
    field :pr, :string

    timestamps
  end

  @required_fields ~w(repo sha status_id status github_user pr)
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
