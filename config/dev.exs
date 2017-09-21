use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :slack_coder, SlackCoder.Endpoint,
  http: [port: 4000],
  debug_errors: false,
  code_reloader: true,
  cache_static_lookup: false,
  check_origin: false,
  watchers: [node: ["node_modules/.bin/webpack", "--watch",
               cd: Path.expand("../", __DIR__)]]

# Watch static and templates for browser reloading.
config :slack_coder, SlackCoder.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{lib/.*(ex)$},
      ~r{web/.*(ex)$},
      ~r{web/.*(eex)$}
    ]
  ]

config :logger,
  backends: [:console]

# Do not include metadata nor timestamps in development logs
config :logger, :console,
  format: "[$level] $message\n",
  level: :info

config :logger,
  truncate: :infinity

# Set a higher stacktrace during development.
# Do not configure such in production as keeping
# and calculating stacktraces is usually expensive.
config :phoenix, :stacktrace_depth, 20

database = if(System.get_env("DATA_DB_USER") == "nanobox", do: "gonano", else: "slack_coder_dev")
# Configure your database
config :slack_coder, SlackCoder.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DATA_DB_USER") || "postgres",
  password: System.get_env("DATA_DB_PASS") || "postgres",
  hostname: System.get_env("DATA_DB_HOST") || "localhost",
  database: database,
  pool_size: 10

if File.exists? "config/dev.secret.exs" do
  import_config "dev.secret.exs"
else
  config :slack_coder,
    slack_api_token: nil,
    personal: true,
    caretaker: :matt,
    travis_token: nil,
    circle_ci_token: nil,
    random_failure_channel: "#some-channel"

  config :slack_coder, :github,
    pat: "a-github-token-that-wont-work",
    user: "ausername"

  config :ueberauth, Ueberauth.Strategy.Github.OAuth,
    client_id: "someclientid",
    client_secret: "someclientsecret"

  config :slack_coder, :notifications,
    min_hour: 0,
    max_hour: 24,
    always_allow: true,
    days: [1,2,3,4,5,6,7]
end
