defmodule SlackCoderTest do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Only start the endpoint and ecto repo
      supervisor(SlackCoder.Endpoint, []),
      worker(SlackCoder.Repo, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SlackCoder.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
