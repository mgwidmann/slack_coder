defmodule SlackCoder.Github.Supervisor do
  import Supervisor.Spec
  require Logger

  def start_link() do
    children = [
      worker(SlackCoder.Github.ShaMapper, []),
      worker(SlackCoder.Github.FailureLogCleaner, []),
      supervisor(SlackCoder.Github.Watchers.Supervisor, [])
    ]

    opts = [strategy: :rest_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end

end
