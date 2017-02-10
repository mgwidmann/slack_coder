defmodule SlackCoder do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the Ecto repository
      worker(SlackCoder.Repo, []),
      # Start the endpoint when the application starts
      supervisor(SlackCoder.Endpoint, []),
      # Start Users supervisor before slack client
      supervisor(SlackCoder.Users.Supervisor, []),
    ]

    children = children ++ if Application.get_env(:slack_coder, :slack_api_token) do
      [ # Define workers and child supervisors to be supervised
        worker(SlackCoder.Slack, [Application.get_env(:slack_coder, :slack_api_token), []])
      ]
    else
      []
    end

    children = children ++ [
      supervisor(SlackCoder.Github.Supervisor, [])
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
