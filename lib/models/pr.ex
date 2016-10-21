defmodule SlackCoder.Models.PR do
  use SlackCoder.Web, :model

  schema "prs" do
    field :owner, :string
    field :statuses_url, :string
    field :repo, :string
    field :branch, :string
    field :github_user, :string
    field :github_user_avatar, :string, virtual: true
    field :fork, :boolean
    # Stale PR checking
    field :latest_comment, Timex.Ecto.DateTime
    field :latest_comment_url, :string, virtual: true
    field :notifications, SlackCoder.Models.Types.StringList, virtual: true, default: []
    field :opened_at, Timex.Ecto.DateTime
    field :closed_at, Timex.Ecto.DateTime
    field :merged_at, Timex.Ecto.DateTime
    field :backoff, :integer, default: Application.get_env(:slack_coder, :pr_backoff_start, 1)
    # Used in view
    field :title, :string
    field :number, :integer
    field :html_url, :string
    field :mergeable, :boolean

    field :webhook, :boolean, virtual: true

    has_many :commits, SlackCoder.Models.Commit

    field :latest_commit, :map, virtual: true

    timestamps
  end

  @required_fields ~w(owner repo branch github_user title number html_url opened_at)
  @optional_fields ~w(statuses_url latest_comment latest_comment_url backoff merged_at closed_at latest_commit mergeable github_user_avatar fork watched)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> cast_assoc(:commits)
  end

  def reg_changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

end
