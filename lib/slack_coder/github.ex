defmodule SlackCoder.Github do
  require Logger

  def client do
    Tentacat.Client.new(%{
      user: Application.get_env(:slack_coder, :github)[:user],
      password: Application.get_env(:slack_coder, :github)[:pat]
    })
  end

  @callback_url "http://#{Application.get_env(:slack_coder, :github)[:callback_host]}/api/github/event"
  @events ~w(push issue_comment commit_comment issues pull_request pull_request_review_comment status)
  @hook_config %{
    name: "web",
    events: @events,
    config: %{
      url: @callback_url,
      content_type: "json"
    }
  }
  def set_hook(owner, repo) do
    with hooks when is_list(hooks) <- Tentacat.Hooks.list(owner, repo, client),
         stream = %Stream{}        <- Stream.each(hooks, &(delete_ngrok(&1, owner, repo))),
         hook when is_map(hook)    <- Enum.find(stream, &find_hook/1) do
       IO.puts "Updating hook id #{hook["id"]}"
       Tentacat.Hooks.update(owner, repo, hook["id"], @hook_config, client)
    else
      _ ->
        case Tentacat.Hooks.create(owner, repo, @hook_config, client) do
          {201, hook} ->
            IO.puts "got hook #{inspect hook}"
            hook
          resp ->
            Logger.warn "Unable to set webhook for #{owner}/#{repo}, response: #{inspect resp}"
            nil
        end
    end
  end

  def events(), do: @events

  defp find_hook(%{"config" => %{"url" => url}}) do
    @callback_url == url
  end

  defp delete_ngrok(%{"config" => %{"url" => url}, "id" => id}, owner, repo) do
    if String.contains?(url, "ngrok") do
      Tentacat.Hooks.remove(owner, repo, id, client)
    end
  end
end
