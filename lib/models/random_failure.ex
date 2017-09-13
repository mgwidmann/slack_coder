defmodule SlackCoder.Models.RandomFailure do
  use SlackCoder.Web, :model

  schema "random_failures" do
    field :owner, :string
    field :repo, :string
    field :pr, :integer
    field :sha, :string
    field :file, :string
    field :line, :string
    field :seed, :integer
    field :count, :integer, default: 0
    field :log_url, :string
    field :type, :string

    timestamps()
  end

  @required_fields ~w(owner repo pr file line)a
  @optional_fields ~w(sha seed count log_url)a
  @all_fields @required_fields ++ @optional_fields

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  def find_unique(query \\ __MODULE__, owner, repo, file, line) do
    import Ecto.Query
    line = to_string(line)
    from q in query, where: q.owner == ^owner and q.repo == ^repo and q.file == ^file and q.line == ^line, limit: 1
  end
end
