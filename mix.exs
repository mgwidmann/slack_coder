defmodule SlackCoder.Mixfile do
  use Mix.Project

  def project do
    [app: :slack_coder,
     version: "0.0.1",
     elixir: "~> 1.3",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:phoenix, :phoenix_html, :cowboy, :logger, :flames, :wobserver,
                   :phoenix_ecto, :slack, :httpoison, :postgrex, :tzdata, :ueberauth_github,
                   :scrivener, :scrivener_html, :scrivener_ecto],
     mod: {SlackCoder, []}]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      ###########################
      #### Prod dependencies ####
      ###########################
      #### Core ####
      {:phoenix, "~> 1.3.0-rc"},
      {:phoenix_html, "~> 2.6"},
      {:cowboy, "~> 1.0"},
      #### Ecto ####
      {:ecto, "~> 2.0", override: true},
      {:absinthe_ecto, github: "mgwidmann/absinthe_ecto", branch: "1.4.0-beta"},
      {:phoenix_ecto, "~> 3.0"},
      {:scrivener_ecto, "~> 1.0"},
      {:timex_ecto, "~> 3.0"},
      {:ecto_enum, "~> 1.0"},
      {:postgrex, "~> 0.11"},
      #### Authentication ####
      {:guardian, "~> 1.0.0-beta.0"},
      {:ueberauth_github, "~> 0.4"},
      #### GraphQL ####
      {:absinthe, "~> 1.4.0-beta.5"},
      {:absinthe_plug, github: "mgwidmann/absinthe_plug", branch: "default_headers_connection"},
      #### Slack ####
      {:slack, github: "BlakeWilliams/Elixir-Slack"},
      {:websocket_client, "~> 1.2", override: true},
      #### Github ####
      {:tentacat, "~> 0.6"},
      #### Misc ####
      {:scrivener_html, "~> 1.5"},
      {:httpoison, "~> 0.10"},
      {:poison, "~> 3.1", override: true},
      ### Testing ####
      {:stub_alias, "~> 0.1.2"}, # Note: Needed for all environments to compile
      #### Monitoring ####
      {:flames, github: "mgwidmann/flames"},
      {:wobserver, "~> 0.1"},

      # Dev only
      {:phoenix_live_reload, "~> 1.0", only: :dev}
    ]
  end

  # Aliases are shortcut or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
