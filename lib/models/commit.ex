defmodule SlackCoder.Models.Commit do
  use SlackCoder.Web, :model
  alias SlackCoder.Github.Helper

  schema "commits" do
    field :sha, :string
    field :latest_status_id, :integer

    field :status, :string
    field :code_climate_status, :string
    field :travis_url, :string
    field :code_climate_url, :string

    field :github_user_avatar, :string, virtual: true

    belongs_to :pr, SlackCoder.Models.PR

    timestamps
  end

  @required_fields ~w(sha status)
  @optional_fields ~w(pr_id latest_status_id code_climate_status travis_url code_climate_url)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def notify_status(changeset) do
    if changeset.changes[:status] && changeset.valid? do
      Helper.report_change(changeset.data)
    end
    changeset
  end

end
