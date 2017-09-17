defmodule SlackCoder.GraphQL.Resolvers.PRResolver do
  alias SlackCoder.Models.PR
  alias SlackCoder.Repo

  def build_status(%PR{build_status: status}) when is_binary(status) do
    String.to_atom(status)
  end
  def build_status(_), do: nil

  def analysis_status(%PR{analysis_status: status}) when is_binary(status) do
    String.to_atom(status)
  end
  def analysis_status(_), do: nil

  def list(current_user, :mine, :open) do
    {:ok, SlackCoder.Github.Watchers.Supervisor.pull_requests()[String.to_atom(current_user.github)]}
  end

  def list(current_user, :mine, :merged) do
    {:ok, PR.by_user(current_user.id) |> PR.merged() |> Repo.all()}
  end
end
