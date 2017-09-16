use Mix.Config
# Put all stubs here with the translation from real
# module to test module inside of test/support/stubs
config :stub_alias,
  "SlackCoder.Users.Supervisor":          SlackCoder.Stubs.Users.Supervisor,
  "SlackCoder.Users.User":                SlackCoder.Stubs.Users.User,
  "SlackCoder.Services.UserService":      SlackCoder.Stubs.UserService,
  "SlackCoder.BuildSystem.Travis":        SlackCoder.Stubs.BuildSystem.Travis,
  "SlackCoder.BuildSystem.Travis.Build":  SlackCoder.Stubs.BuildSystem.Travis.Build,
  "SlackCoder.BuildSystem.CircleCI":      SlackCoder.Stubs.BuildSystem.CircleCI,
  "SlackCoder.BuildSystem.Semaphore":     SlackCoder.Stubs.BuildSystem.Semaphore

config :slack,
  rtm_module:       SlackCoder.Stubs.SlackRtm,
  websocket_client: SlackCoder.Stubs.WebsocketClient
