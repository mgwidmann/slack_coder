defmodule SlackCoder.Mixfile do
  use Mix.Project

  def project do
    [app: :slack_coder,
     version: "0.0.1",
     elixir: "~> 1.2",
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
    [applications: [:phoenix, :phoenix_html, :cowboy, :logger, :beaker,
                   :phoenix_ecto, :slack, :httpoison, :postgrex, :tzdata],
     mod: mod(Mix.env)]
  end

  defp mod(:test), do: {SlackCoderTest, []}
  defp mod(_), do: {SlackCoder, []}

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
      {:phoenix, "~> 1.1.0"},
      {:phoenix_ecto, github: "phoenixframework/phoenix_ecto", override: true},
      {:postgrex, "~> 0.10"},
      {:phoenix_html, "~> 2.3"},
      {:cowboy, "~> 1.0"},
      {:timex_ecto, "~> 0.6"},
      # {:slack, "~> 0.2.0"},
      {:slack, git: "https://github.com/mgwidmann/Elixir-Slack", branch: "im_list"},
      # {:slack, path: "../Elixir-Slack"},
      {:websocket_client, git: "https://github.com/mgwidmann/websocket_client.git", override: true, branch: "fix_error_logging"},
      # {:websocket_client, git: "https://github.com/jeremyong/websocket_client.git"},
      {:httpoison, "~> 0.7.2"},
      {:exjsx, "~> 3.1"},
      # {:ecto, "~> 1.1.0"},
      {:ecto, github: "elixir-lang/ecto", override: true},
      {:oauth2, "~> 0.5"},
      {:beaker, ">= 1.2.0"},

      # Dev only
      {:phoenix_live_reload, "~> 1.0", only: :dev},

      # Test only
      {:pavlov, github: "sproutapp/pavlov", only: :test}
    ]
  end
end
