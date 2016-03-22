defmodule SlackCoder.Repo do
  use Ecto.Repo, otp_app: :slack_coder
  use Beaker.Integrations.Ecto

  def save(%Ecto.Changeset{model: %{id: nil}} = changeset) do
    insert(changeset)
  end

  def save(%Ecto.Changeset{model: %{id: _id}} = changeset) do
    update(changeset)
  end

  # Fun addition
  def count(queryable) do
    import Ecto.Query
    one(from q in queryable, select: count(q.id))
  end

  def first(queryable) do
    import Ecto.Query
    all(from q in queryable, limit: 1) |> List.first
  end
end
