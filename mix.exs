defmodule SlackCoder.Mixfile do
  use Mix.Project

  def project do
    [app: :slack_coder,
     version: "0.0.1",
     elixir: "~> 1.0",
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
    [applications: [:phoenix, :phoenix_html, :cowboy, :logger,
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
      {:phoenix, "~> 1.0.0"},
      {:phoenix_ecto, "~> 1.1"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.2"},
      {:cowboy, "~> 1.0"},
      {:timex_ecto, "~> 0.5.0"},
      # {:slack, "~> 0.2.0"},
      {:slack, git: "https://github.com/mgwidmann/Elixir-Slack", branch: "im_list"},
      # {:slack, path: "../Elixir-Slack"},
      {:websocket_client, git: "https://github.com/mgwidmann/websocket_client.git", override: true, branch: "fix_error_logging"},
      # {:websocket_client, git: "https://github.com/jeremyong/websocket_client.git"},
      {:httpoison, "~> 0.7.2"},
      {:exjsx, "~> 3.1"},
      {:ecto, "~> 1.0.0"},
      {:oauth2, "~> 0.5"},

      # Dev only
      {:phoenix_live_reload, "~> 1.0", only: :dev},

      # Test only
      {:pavlov, "~> 0.2.3", only: :test}
    ]
  end
end
