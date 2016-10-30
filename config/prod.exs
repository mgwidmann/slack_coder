use Mix.Config

config :slack_coder, SlackCoder.Endpoint,
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  http: [port: {:system, "PORT"}],
  url: [host: "slack-coder.herokuapp.com", port: 80],
  cache_static_manifest: "priv/static/manifest.json"

# Do not print debug messages in production
config :logger, level: :info

config :slack_coder, SlackCoder.Repo,
  adapter: Ecto.Adapters.Postgres,
  # url: "postgres://postgres:postgres@localhost/slack_coder",
  url: System.get_env("DATABASE_URL"),
  size: 20

if File.exists? "config/prod.secret.exs" do
  import_config "prod.secret.exs"
end
