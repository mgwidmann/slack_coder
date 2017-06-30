defmodule SlackCoder.Github do
  require Logger
  alias SlackCoder.Github.EventProcessor
  alias SlackCoder.Services.UserService

  def client do
    Tentacat.Client.new(%{
      user: Application.get_env(:slack_coder, :github)[:user],
      password: Application.get_env(:slack_coder, :github)[:pat]
    })
  end

  def query(query, variables, client \\ client()) do
    "https://#{client.auth.user}:#{client.auth.password}@api.github.com/graphql"
    |> HTTPoison.post(Poison.encode!(%{query: query, variables: variables}))
    |> extract_response(query)
  end

  defp extract_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}, _query) do
    Poison.decode(body)
  end
  defp extract_response({:error, %HTTPoison.Error{reason: :timeout} = error}, _query) do
    # Ignore
    error
  end
  defp extract_response({:error, %HTTPoison.Error{} = error}, query) do
    Logger.warn([
      IO.ANSI.green, IO.ANSI.bright, "[SlackCoder.Github] ",
      IO.ANSI.default_color, IO.ANSI.normal, "Error running GraphQL query: ",
      inspect(error), "\n",
      query
    ])
    error
  end

  @events ~w(commit_comment create delete deployment deployment_status download follow fork fork_apply gist
    gollum issue_comment issues label member membership milestone organization page_build ping public pull_request pull_request_review
    pull_request_review_comment push release repository status team team_add watch)
  def events(), do: @events

  def synchronize(owner, repository) do
    raw_prs = Tentacat.Pulls.list(owner, repository, client())
    raw_prs |> Enum.each(fn(pr)->
      pr["user"]["login"]
      |> Tentacat.Users.find(client())
      |> UserService.find_or_create_user()

      pr = Tentacat.Pulls.find(owner, repository, pr["number"], client())
      EventProcessor.process(:pull_request, %{"action" => "opened", "number" => pr["number"], "pull_request" => pr})
    end)
  end

  def synchronize_pull_request(owner, repository, number) do
    pr = Tentacat.Pulls.find(owner, repository, to_string(number), client())
    EventProcessor.process(:pull_request, %{"action" => "opened", "number" => pr["number"], "pull_request" => pr})
  end
end
