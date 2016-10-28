defmodule SlackCoder.Github.Supervisor do
  import Supervisor.Spec
  alias SlackCoder.Repo
  alias SlackCoder.Models.PR
  require Logger

  def start_link() do
    children = [
      worker(SlackCoder.Github.ShaMapper, []),
      supervisor(SlackCoder.Github.Watchers.Supervisor, [])
    ]

    opts = [strategy: :rest_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end

end
