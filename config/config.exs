use Mix.Config

config :slack_coder, SlackCoder.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "slack_coder_development",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"


config :slack_coder,
  slack_api_token: "Find your token here: https://api.slack.com/web",
  github: [
    pat: "Create your token here: https://github.com/settings/tokens",
    user: "your-user-name",
  ],
  users: [],
  repos: [],
  channel: nil,
  group: nil

import_config "#{Mix.env}.exs"
