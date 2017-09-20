defmodule SlackCoder.BuildSystem.Travis.Job do
  use HTTPoison.Base

  defp process_url(url) do
    "https://api.travis-ci.com" <> url
  end

  defp process_response_body(body) do
    body
  end

  defp process_request_headers(headers) do
    token = Application.get_env(:slack_coder, :travis_token)
    [{"Authorization", "token #{token}"} | headers]
  end
end
