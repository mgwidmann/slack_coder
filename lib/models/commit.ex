defmodule SlackCoder.Models.Commit do
  use Ecto.Model

  schema "commits" do
    field :sha, :string
    field :latest_status_id, :integer

    field :status, :string
    field :code_climate_status, :string
    field :travis_url, :string
    field :code_climate_url, :string
    field :github_user, :string, virtual: true
    field :github_user_avatar, :string, virtual: true

    belongs_to :pr, SlackCoder.Models.PR

    timestamps
  end

  after_insert __MODULE__, :notify_status
  after_update __MODULE__, :notify_status

  @required_fields ~w(sha pr_id status latest_status_id code_climate_status travis_url code_climate_url)
  @optional_fields ~w(github_user github_user_avatar)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def notify_status(changeset) do

  end

end
