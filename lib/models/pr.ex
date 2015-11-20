defmodule SlackCoder.Models.PR do
  use Ecto.Model

  schema "prs" do
    field :owner, :string
    field :statuses_url, :string
    field :repo, :string
    field :branch, :string
    field :github_user, :string
    # Stale PR checking
    field :latest_comment, Ecto.DateTime
    field :backoff, :integer
    # Used in view
    field :title, :string
    field :number, :integer
    field :html_url, :string

    has_many :commits, SlackCoder.Models.Commit

    field :latest_commit, :map, virtual: true

    timestamps
  end

  @required_fields ~w(owner repo branch github_user title number html_url)
  @optional_fields ~w(statuses_url latest_comment backoff)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

end
