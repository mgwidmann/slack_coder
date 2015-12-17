defmodule SlackCoder.Models.User do
  use SlackCoder.Web, :model

  schema "users" do
    field :slack, :string
    field :github, :string
    field :avatar_url, :string
    field :html_url, :string
    field :name, :string
    field :monitors, StringList

    embeds_one :config, SlackCoder.Models.User.Config

    timestamps
  end

  @required_fields ~w(slack github config)
  @optional_fields ~w(avatar_url html_url name config monitors)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:slack)
    |> unique_constraint(:github)
  end

  def by_slack(name) when is_binary(name) do
    from u in __MODULE__, where: u.slack == ^name
  end
  def by_slack(names) when is_list(names) do
    from u in __MODULE__, where: u.slack in ^names
  end
  def by_slack(name), do: to_string(name) |> by_slack

  def by_github(name) when is_binary(name) do
    from u in __MODULE__, where: u.github == ^name
  end
  def by_github(names) when is_list(names) do
    from u in __MODULE__, where: u.github in ^names
  end
  def by_github(name), do: to_string(name) |> by_slack
end
