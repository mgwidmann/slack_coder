use Mix.Config

config :logger, :console,
  level: :error

config :slack_coder,
  slack_api_token: "a-token",
  github: [
    pat: "pat-123",
    user: "slack_coder",
  ],
  users: [
    cool_project: [
      slack_coder: [slack: :slack_coder]
    ],
    some_idea: [
      slack_coder: [slack: :slack_coder]
    ]
  ],
  repos: [
    cool_project: [
      owner: :slack_coder
    ],
    some_idea: [
      owner: :slack_coder
    ]
  ],
  channel: "slack_coder_channel",
  group: "slack_coder_group"
