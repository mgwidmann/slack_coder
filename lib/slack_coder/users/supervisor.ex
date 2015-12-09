defmodule SlackCoder.Users.Supervisor do
  import Supervisor.Spec
  require Logger

  def start_link() do
    users = Application.get_env(:slack_coder, :users, [])
            |> Keyword.keys
            |> Enum.map(&SlackCoder.Config.slack_user/1)
            |> Enum.uniq
    children = users |> Enum.map(fn(user)->
      worker(SlackCoder.Users.User, [user], id: "User-#{user}")
    end)

    opts = [strategy: :one_for_one, name: SlackCoder.Users.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def user(slack) when is_atom(slack), do: to_string(slack) |> user
  def user(slack) do
    child = Supervisor.which_children(__MODULE__)
            |> Enum.find(&(match?({"User-" <> ^slack, _, _, _}, &1)))
    case child do
      nil -> nil
      {_, worker, _, _} -> worker
    end
  end

end
