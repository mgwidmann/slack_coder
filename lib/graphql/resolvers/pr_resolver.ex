defmodule SlackCoder.GraphQL.Resolvers.PRResolver do
  alias SlackCoder.Models.{PR, User}
  alias SlackCoder.Repo
  import Ecto.Query
  alias SlackCoder.Github.Watchers.Supervisor, as: Github
  alias SlackCoder.Github.Watchers.PullRequest

  def build_status(%PR{build_status: status}) when is_binary(status) do
    String.to_atom(status)
  end
  def build_status(_), do: nil

  def analysis_status(%PR{analysis_status: status}) when is_binary(status) do
    String.to_atom(status)
  end
  def analysis_status(_), do: nil

  def list(current_user, :mine, :open) do
    {:ok, PR.by_user(current_user.id) |> PR.active() |> Repo.all()}
  end

  def list(current_user, :mine, :merged) do
    {:ok, PR.by_user(current_user.id) |> PR.merged() |> Repo.all()}
  end

  def list(%User{monitors: monitors}, :monitors, :open) do
    {:ok, PR.by_github(monitors) |> order_by([p], [desc: p.user_id]) |> PR.active() |> Repo.all()}
  end

  def list(%User{monitors: monitors}, :monitors, :merged) do
    {:ok, PR.by_github(monitors) |> order_by([p], [desc: p.user_id]) |> PR.merged() |> Repo.all()}
  end

  def pull_request(_, %{owner: owner, repository: repo, number: number}, _) do
    {:ok, PR.by_number(owner, repo, number) |> Repo.one!()}
  end

  def pull_request(_, %{id: id}, _) do
    {:ok, Repo.get!(PR, id)}
  end

  def synchronize(_, %{owner: owner, repository: repo, number: number}, _) do
    SlackCoder.Github.synchronize_pull_request(owner, repo, number)

    {:ok, %PR{owner: owner, repo: repo, number: number}
          |> Github.find_watcher()
          |> PullRequest.fetch()}
  end
end
