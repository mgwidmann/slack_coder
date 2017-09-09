use Mix.Config
# Put all stubs here with the translation from real
# module to test module inside of test/support/stubs
config :stub_alias,
  "SlackCoder.Users.Supervisor":  SlackCoder.Stubs.Users.Supervisor,
  "SlackCoder.Users.User":        SlackCoder.Stubs.Users.User,
  "SlackCoder.Travis":            SlackCoder.Stubs.Travis,
  "SlackCoder.Travis.Build":      SlackCoder.Stubs.Travis.Build

config :slack,
  rtm_module:       SlackCoder.Stubs.SlackRtm,
  websocket_client: SlackCoder.Stubs.WebsocketClient
