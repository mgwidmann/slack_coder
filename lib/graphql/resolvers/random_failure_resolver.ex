defmodule SlackCoder.GraphQL.Resolvers.RandomFailureResolver do
  alias SlackCoder.Repo
  alias SlackCoder.Models.RandomFailure
  import Ecto.Query

  def list(_, params, _) do
    failures = RandomFailure
               |> order_clause(params)
               |> Repo.paginate(params)
    {:ok, failures}
  end

  defp order_clause(query, %{sort: :count} = params) do
    dir = params[:dir] || :desc
    order_by(query, [q], [{^dir, q.count}])
  end
  defp order_clause(query, %{sort: :recent} = params) do
    dir = params[:dir] || :desc
    order_by(query, [q], [{^dir, q.updated_at}])
  end
  defp order_clause(query, _params), do: query

end
