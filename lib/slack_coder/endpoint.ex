defmodule SlackCoder.Endpoint do
  use Phoenix.Endpoint, otp_app: :slack_coder

  plug Beaker.Integrations.Phoenix

  socket "/socket", SlackCoder.UserSocket

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/", from: :slack_coder, gzip: false,
    only: ~w(css fonts images js 404.html 500.html favicon.png robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_slack_coder_key",
    signing_salt: "rPDcc861"

  plug SlackCoder.Router
end
