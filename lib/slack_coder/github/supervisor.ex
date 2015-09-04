defmodule SlackCoder.Github.Supervisor do
  import Supervisor.Spec

  def start_link() do
    IO.puts "#{__MODULE__}.start_link"
    repos = Application.get_env(:slack_coder, :repos, []) |> Keyword.keys
    children = repos |> Enum.map(fn(repo)->
      worker(SlackCoder.Github.PullRequest, [repo], id: "Repo-#{repo}")
    end)

    opts = [strategy: :one_for_one, name: SlackCoder.Github.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def start_watcher(pr) do
    Supervisor.start_child(SlackCoder.Github.Supervisor,
      worker(SlackCoder.Github.PullRequest.Watcher, [pr], id: "PR-#{pr.number}"))
  end

end
