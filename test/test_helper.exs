ExUnit.start()
ExUnit.configure(exclude: [pending: true])

Ecto.Adapters.SQL.Sandbox.mode(SlackCoder.Repo, :auto)
