defmodule SlackCoder.Repo do
  use Ecto.Repo, otp_app: :slack_coder
  use Scrivener

  # Fun addition
  def count(queryable) do
    import Ecto.Query
    one(from q in queryable, select: count(q.id))
  end

  def last(queryable) do
    import Ecto.Query
    one(from q in queryable, order_by: q.id, limit: 1)
  end
end
