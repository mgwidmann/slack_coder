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

  def for_sha(query \\ __MODULE__, sha) do
    from log in query, where: log.sha == ^sha
  end

  def with_external_ids(query \\ __MODULE__, ids) do
    ids = List.wrap(ids)
    from log in query, where: log.external_id in ^ids
  end

  def without_random_failure(query \\ __MODULE__, id) do
    from log in query, join: r in assoc(log, :random_failure), where: log.id == ^id, select: true
  end
end
