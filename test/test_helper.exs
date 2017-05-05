ExUnit.start()
ExUnit.configure(exclude: [pending: true])

Mix.Task.run "ecto.create", ["--quiet"]
Mix.Task.run "ecto.migrate", ["--quiet"]
# Ecto.Adapters.SQL.Sandbox.mode(SlackCoder.Repo, :manual)
