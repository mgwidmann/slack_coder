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

  def run_command(%RandomFailure{type: type, file: file, line: line, seed: seed}) do
    "#{command_for_type(type)} #{file}:#{line}#{seed_for_type(type, seed)}"
  end

  for t <- ~w(rspec cucumber) do
    defp command_for_type(unquote(t)), do: "bundle exec #{unquote(t)}"
  end
  defp command_for_type(type), do: type

  for t <- ~w(rspec cucumber) do
    defp seed_for_type(unquote(t), seed), do: " --seed #{seed}"
  end
  defp seed_for_type(_, _), do: nil

end
