defmodule SlackCoder.Users.Supervisor do
  import Supervisor.Spec
  require Logger

  def start_link() do
    users = SlackCoder.Repo.all(SlackCoder.Models.User)
    children = users |> Enum.map(fn(user)->
      user_spec(user)
    end)

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end

  def start_user(user) do
    case Supervisor.start_child(__MODULE__, user_spec(user)) do
      {:ok, user_pid} ->
        user_pid
      {:error, {:already_started, user_pid}} ->
        SlackCoder.Users.User.update(user_pid, user)
        user_pid
      {:error, :already_present} ->
        user_pid = user(user.slack)
        SlackCoder.Users.User.update(user_pid, user)
        user_pid
    end
  end

  defp user_spec(user), do: worker(SlackCoder.Users.User, [user], id: "User-#{user.slack}-#{user.github}")

  def user(slack_or_github) when is_atom(slack_or_github), do: to_string(slack_or_github) |> user
  def user(slack_or_github) do
    child = Supervisor.which_children(__MODULE__)
            |> Enum.find(fn {id, _, _, _}->
              Regex.match?(~r/User-#{slack_or_github}-.*/, id) || Regex.match?(~r/User-.*?-#{slack_or_github}/, id)
            end)
    case child do
      nil -> nil
      {_, user_pid, _, _} -> user_pid
    end
  end

  def users() do
    Supervisor.which_children(__MODULE__)
    |> Enum.map(fn
      {_, user_pid, _, _} -> SlackCoder.Users.User.get(user_pid)
    end)
  end

end
