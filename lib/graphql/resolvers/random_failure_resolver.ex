defmodule SlackCoder.GraphQL.Resolvers.RandomFailureResolver do
  alias SlackCoder.Repo
  alias SlackCoder.Models.RandomFailure
  alias SlackCoder.Models.RandomFailure.FailureLog
  import Ecto.Query

  @priority_timeframe 60 # Minute

  def list(_, params, _) do
    failures = RandomFailure
               |> RandomFailure.unresolved()
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
  defp order_clause(query, %{sort: :priority} = params) do
    dir = params[:dir] || :desc
    order_by(query, [q], [{^dir, fragment("POWER(EXTRACT(epoch from (? - ?))/? + 1, ?)", q.updated_at, q.inserted_at, type(^@priority_timeframe, :integer), q.count)}])
  end
  defp order_clause(query, _params), do: query

  def log_url(%FailureLog{id: id}) do
    SlackCoder.Router.Helpers.random_failure_url(SlackCoder.Endpoint, :log, id)
  end

  def run_command(%RandomFailure{type: type, file: file, line: line, seed: seed}) do
    "#{command_for_type(type)} #{file}:#{line}#{seed_for_type(type, seed)}"
  end

  def priority_score(%RandomFailure{inserted_at: inserted, updated_at: updated, count: count}) do
    unix_updated = (DateTime.from_naive!(updated, "Etc/UTC") |> DateTime.to_unix()) / @priority_timeframe
    unix_inserted = (DateTime.from_naive!(inserted, "Etc/UTC") |> DateTime.to_unix()) / @priority_timeframe
    :math.pow(unix_updated - unix_inserted + 1, count)
  end

  for t <- ~w(rspec cucumber)a do
    defp command_for_type(unquote(t)), do: "bundle exec #{unquote(t)}"
  end
  defp command_for_type(:minitest), do: "bin/rails test"
  defp command_for_type(type), do: type

  for t <- ~w(rspec)a do
    defp seed_for_type(unquote(t), seed), do: " --seed #{seed}"
  end
  defp seed_for_type(:minitest, seed), do: " TESTOPTS=\"--seed #{seed}\""
  defp seed_for_type(_, _), do: nil

  def resolve(_, %{id: id}, _) do
    failure = Repo.get!(RandomFailure, id)
    changeset = RandomFailure.changeset(failure, %{resolved: true})
    Repo.update(changeset)
  end
end
