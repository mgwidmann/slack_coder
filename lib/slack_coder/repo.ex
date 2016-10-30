defmodule SlackCoder.Repo do
  use Ecto.Repo, otp_app: :slack_coder
  use Beaker.Integrations.Ecto

  # Fun addition
  def count(queryable) do
    import Ecto.Query
    one(from q in queryable, select: count(q.id))
  end
end
