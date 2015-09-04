use Mix.Config

config :logger, :console,
  level: :debug

import_config "dev.secret.exs"
