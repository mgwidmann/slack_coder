ExUnit.start()
ExUnit.configure(exclude: [pending: true], trace: true)

Ecto.Adapters.SQL.Sandbox.mode(SlackCoder.Repo, :auto)
