defmodule SlackCoder.Models.RandomFailure.FailureLog do
  use SlackCoder.Web, :model
  alias SlackCoder.Models.{PR, RandomFailure}

  schema "failure_logs" do
    belongs_to :pr, PR
    field :log, :string
    field :external_id, :integer
    field :sha, :string

    has_one :random_failure, RandomFailure

    timestamps()
  end

  @required_fields ~w(log external_id)a
  @optional_fields ~w(pr_id sha)a
  @all_fields @required_fields ++ @optional_fields

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  def by_pr(query \\ __MODULE__, %PR{id: id}) do
    from log in query, where: log.pr_id == ^id
  end

  def with_external_id(query \\ __MODULE__, id) do
    from log in query, where: log.external_id == ^id
  end
end
