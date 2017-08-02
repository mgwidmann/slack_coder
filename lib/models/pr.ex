defmodule SlackCoder.Models.PR do
  use SlackCoder.Web, :model

  schema "prs" do
    field :owner, :string
    field :repo, :string
    field :branch, :string
    field :fork, :boolean
    # Stale PR checking
    field :latest_comment, Timex.Ecto.DateTime
    field :latest_comment_url, :string
    field :notifications, SlackCoder.Models.Types.StringList, virtual: true, default: []
    field :opened, :boolean, default: false
    field :opened_at, Timex.Ecto.DateTime
    field :closed_at, Timex.Ecto.DateTime
    field :merged_at, Timex.Ecto.DateTime
    field :backoff, :integer, default: Application.get_env(:slack_coder, :pr_backoff_start, 1)
    # Used in view
    field :title, :string
    field :number, :integer
    field :html_url, :string
    field :mergeable, :boolean
    field :github_user, :string
    field :github_user_avatar, :string
    # Build status info
    field :sha, :string
    field :build_status, :string
    field :analysis_status, :string
    field :build_url, :string
    field :analysis_url, :string

    belongs_to :user, SlackCoder.Models.User

    timestamps()
  end

  @required_fields ~w(owner repo branch github_user title number html_url opened_at)a
  @optional_fields ~w(latest_comment latest_comment_url notifications backoff merged_at closed_at mergeable
                      github_user_avatar fork sha build_status analysis_status build_url analysis_url user_id)a
  @all_fields @required_fields ++ @optional_fields
  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> cast_assoc(:commits)
    |> update_status()
  end

  def update_status(changeset = %Ecto.Changeset{changes: %{sha: sha}}) when not is_nil(sha) do
    changeset
    |> put_change(:build_status, "pending")
    |> put_change(:analysis_status, "pending")
  end
  def update_status(cs), do: cs

  def reg_changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  def active(query \\ __MODULE__) do
    from pr in query, where: is_nil(pr.closed_at) and is_nil(pr.merged_at)
  end

  def by_number(query \\ __MODULE__, owner, repo, number) do
    from pr in query, where: pr.owner == ^owner and pr.repo == ^repo and pr.number == ^number
  end

end
