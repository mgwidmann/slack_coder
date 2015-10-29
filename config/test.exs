use Mix.Config

config :slack_coder, SlackCoder.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "slack_coder_test",
  username: System.get_env("DATABASE_POSTGRESQL_USERNAME") || "postgres",
  password: System.get_env("DATABASE_POSTGRESQL_PASSWORD") || "postgres",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :slack_coder,
  slack_api_token: "a-token",
  github: [
    pat: "pat-123",
    user: "slack_coder",
  ],
  users: [
    slack_coder: [slack: :slack_coder]
  ],
  repos: [
    cool_project: [
      owner: :slack_coder,
      users: [
        :slack_coder
      ]
    ],
    some_idea: [
      owner: :slack_coder,
      users: [
        :slack_coder
      ]
    ]
  ],
  channel: "slack_coder_channel",
  group: "slack_coder_group"

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :slack_coder, SlackCoder.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Set a higher stacktrace during test
config :phoenix, :stacktrace_depth, 20
