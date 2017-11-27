defmodule SlackCoder.Models.RandomFailure do
  use SlackCoder.Web, :model
  alias SlackCoder.Models.RandomFailure.{RunType, CISystem, FailureLog}

  schema "random_failures" do
    field :owner, :string
    field :repo, :string
    field :pr, :integer
    field :sha, :string
    field :file, :string
    field :line, :string
    field :seed, :integer
    field :count, :integer, default: 0
    field :type, RunType
    field :system, CISystem
    field :description, :string
    field :resolved, :boolean

    belongs_to :failure_log, FailureLog

    timestamps()
  end

  @required_fields ~w(owner repo pr file line)a
  @optional_fields ~w(description sha seed count system type resolved)a
  @all_fields @required_fields ++ @optional_fields

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  def find_unique(query \\ __MODULE__, owner, repo, file, line, description) do
    import Ecto.Query
    from q in query,
      where: q.owner == ^owner and q.repo == ^repo and q.file == ^file and q.description == ^description or
        q.owner == ^owner and q.repo == ^repo and q.file == ^file and q.line == ^line,
      limit: 1
  end

  def by_repo(query \\ __MODULE__, owner, repo) do
    import Ecto.Query
    from q in query,
      where: q.owner == ^owner and q.repo == ^repo
  end

  def unresolved(query \\ __MODULE__) do
    import Ecto.Query
    from q in query, where: q.resolved == ^false
  end
end
