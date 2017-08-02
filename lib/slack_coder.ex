defmodule SlackCoder do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the Ecto repository
      worker(SlackCoder.Repo, []),
      supervisor(Task.Supervisor, [[name: SlackCoder.TaskSupervisor]]),
      # Start the endpoint when the application starts
      supervisor(SlackCoder.Endpoint, []),
      # Start Users supervisor before slack client
      supervisor(SlackCoder.Users.Supervisor, []),
    ]

    children = children ++ if Application.get_env(:slack_coder, :slack_api_token) do
      [ # Define workers and child supervisors to be supervised
        worker(Slack.Bot, [SlackCoder.Slack, nil, Application.get_env(:slack_coder, :slack_api_token), %{client: Application.get_env(:slack, :websocket_client, :websocket_client)}])
      ]
    else
      []
    end

    children = children ++ [
      worker(SlackCoder.Github.Watchers.MergeConflict, []),
      # supervisor(SlackCoder.Github.Supervisor, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SlackCoder.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SlackCoder.Endpoint.config_change(changed, removed)
    :ok
  end
end
