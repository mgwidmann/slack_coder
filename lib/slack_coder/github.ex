defmodule SlackCoder.Github do
  def client do
    Tentacat.Client.new(%{
      user: Application.get_env(:slack_coder, :github)[:user],
      password: Application.get_env(:slack_coder, :github)[:pat]
    })
  end

  @callback_url "http://#{Application.get_env(:slack_coder, :github)[:callback_host]}/api/github/event"
  @hook_config %{
    name: "web",
    events: ["push", "issue_comment", "commit_comment", "issues", "pull_request", "pull_request_review_comment", "status"],
    config: %{
      url: @callback_url,
      content_type: "json"
    }
  }
  def set_hook(owner, repo) do
    hooks = Tentacat.Hooks.list(owner, repo, client)
    hook = hooks |> Enum.find(&find_hook/1)
    if hook do
      hook = Tentacat.Hooks.update(owner, repo, hook["id"], @hook_config, client)
    else
      hooks |> Enum.each(&(delete_ngrok(&1, owner, repo)))
      {201, hook} = Tentacat.Hooks.create(owner, repo, @hook_config, client)
    end
    hook
  end

  defp find_hook(%{"config" => %{"url" => url}}) do
    @callback_url == url
  end

  defp delete_ngrok(%{"config" => %{"url" => url}, "id" => id}, owner, repo) do
    if String.contains?(url, "ngrok") do
      Tentacat.Hooks.remove(owner, repo, id, client)
    end
  end
end
