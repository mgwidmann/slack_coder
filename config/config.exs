use Mix.Config

# Configures the endpoint
config :slack_coder, SlackCoder.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "nHDNPeBEPIE+B6ltD8exVpSo2aISVfImcTrZhy6Uogg8nGmGNo/882R/HejimCIZ",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: SlackCoder.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :slack_coder,
  slack_api_token: "Find your token here: https://api.slack.com/web",
  github: [
    pat: "Create your token here: https://github.com/settings/tokens",
    user: "your-user-name",
  ],
  repos: [],
  channel: nil,
  group: nil,
  timezone: "America/New_York",
  pr_backoff_start: 2

config :slack_coder, :github_oauth,
  client_id: "your-github-client-id",
  client_secret: "your-github-client-secret",
  redirect_uri: "http://localhost:4000/auth/github/callback"

config :slack_coder, ecto_repos: [SlackCoder.Repo]

config :flames,
  repo: SlackCoder.Repo,
  endpoint: SlackCoder.Endpoint

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :logger,
  backends: [:console, Flames.Logger]

import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false
