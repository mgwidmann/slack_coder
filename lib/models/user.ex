defmodule SlackCoder.Models.User do
  use SlackCoder.Web, :model

  schema "users" do
    field :slack, :string
    field :github, :string
    field :avatar_url, :string
    field :html_url, :string
    field :name, :string
    field :monitors, StringList, default: []
    field :muted, :boolean, default: false

    field :admin, :boolean, default: false

    embeds_one :config, SlackCoder.Models.User.Config

    timestamps
  end

  @required_fields ~w(slack github)
  @optional_fields ~w(avatar_url html_url name monitors muted)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> cast_embed(:config, required: true)
    |> unique_constraint(:slack)
    |> unique_constraint(:github)
  end

  @admin_fields Enum.uniq(~w(admin) ++ @required_fields)
  @admin_required ~w(github)
  def admin_changeset(model, params \\ %{}) do
    model
    |> cast(params, @admin_required, @optional_fields ++ @admin_fields)
  end

  for field <- [:slack, :github] do
    def unquote(:"by_#{field}")(name) when is_binary(name) do
      from u in __MODULE__, where: u.unquote(field) == ^name
    end
    def unquote(:"by_#{field}")(names) when is_list(names) do
      from u in __MODULE__, where: u.unquote(field) in ^names
    end
    def unquote(:"by_#{field}")(name), do: to_string(name) |> unquote(:"by_#{field}")()
  end

end
