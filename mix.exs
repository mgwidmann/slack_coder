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
     deps: deps]
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
      # Prod dependencies
      {:phoenix, "~> 1.2.0"},
      {:phoenix_ecto, "~> 3.0"},
      {:postgrex, "~> 0.11"},
      {:phoenix_html, "~> 2.6"},
      {:cowboy, "~> 1.0"},
      {:timex_ecto, "~> 3.0"},
      {:slack, "~> 0.10.0"},
      {:websocket_client, git: "https://github.com/mgwidmann/websocket_client.git", override: true, branch: "fix_error_logging"},
      # {:websocket_client, git: "https://github.com/jeremyong/websocket_client.git"},
      {:tentacat, "~> 0.6"},
      {:httpoison, "~> 0.10"},
      {:exjsx, "~> 3.2", override: true},
      {:ecto, "~> 2.0", override: true},
      {:ueberauth_github, "~> 0.4"},
      {:stub_alias, github: "mgwidmann/stub_alias"},
      {:scrivener_html, "~> 1.5"},
      {:scrivener_ecto, "~> 1.0"},

      # Monitoring
      # {:flames, "~> 0.2"},
      {:flames, github: "mgwidmann/flames", branch: "insert_errors"},
      {:wobserver, "~> 0.1"},

      # Dev only
      {:phoenix_live_reload, "~> 1.0", only: :dev}
    ]
  end
end
