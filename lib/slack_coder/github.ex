defmodule SlackCoder.Github do
  require Logger
  use PatternTap
  alias SlackCoder.Github.EventProcessor
  alias SlackCoder.Services.UserService
  alias SlackCoder.Github.ShaMapper
  import SlackCoder.Github.TimeHelper
  import HTTPoison.Retry

  def client do
    Tentacat.Client.new(%{
      user: Application.get_env(:slack_coder, :github)[:user],
      password: Application.get_env(:slack_coder, :github)[:pat]
    })
  end

  def query(query, variables, client \\ client()) do
    "https://#{client.auth.user}:#{client.auth.password}@api.github.com/graphql"
    |> HTTPoison.post(Poison.encode!(%{query: query, variables: variables}))
    |> autoretry()
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
    pull_request_review_comment push release repository status team team_add watch project_card)
  def events(), do: @events

  def synchronize(owner, repository) do
    raw_prs = Tentacat.Pulls.list(owner, repository, client())
    raw_prs |> Enum.each(fn(pr)->
      pr["user"]["login"]
      |> Tentacat.Users.find(client())
      |> UserService.find_or_create_user()

      synchronize_pull_request(owner, repository, pr["number"])
    end)
  end

  @pull_request_query """
  query ($owner: String!, $name: String!, $number: Int!) {
    repository(owner: $owner, name: $name) {
      owner {
        login
        avatarUrl
      }
      name
      pullRequest(number: $number) {
        baseRefName
        createdAt
        mergedAt
        closed
        headRepositoryOwner {
          login
          avatarUrl
        }
        mergeable
        url
        number
        title
  			headRefName
      	commits(last: 1) {
          nodes {
            commit {
              oid
              status {
                contexts {
                  targetUrl
                  context
                  state
                }
              }
            }
          }
        }
      }
    }
  }
  """
  def synchronize_pull_request(owner, repository, number) when is_binary(number) do
    {number, _} = Integer.parse(number)
    synchronize_pull_request(owner, repository, number)
  end
  def synchronize_pull_request(owner, repository, number) do
    query(@pull_request_query, %{owner: owner, name: repository, number: number})
    |> pr_response()
  end

  defp pr_response({:ok, %{"data" => %{
    "repository" => %{
      "owner" => %{
        "login" => owner,
        "avatarUrl" => owner_avatar_url
      },
      "name" => repository,
      "pullRequest" => %{
        "baseRefName" => base_branch,
        "createdAt" => created_at,
        "mergedAt" => merged_at,
        "closed" => closed?,
        "headRepositoryOwner" => repo_owner,
        "mergeable" => mergeable_state,
        "url" => html_url,
        "number" => number,
        "title" => title,
        "headRefName" => branch,
        "commits" => %{
            "nodes" => [
              %{
                "commit" => %{
                  "oid" => sha,
                  "status" => %{
                    "contexts" => statuses
                  }
                }
              }
            ]
          }
        }
      }
    }
  }}) do
    {user, user_avatar_url} = {repo_owner["login"] || owner, repo_owner["avatarUrl"] || owner_avatar_url}
    pr = %{
      owner: owner,
      repo: repository,
      branch: branch,
      base_branch: base_branch,
      opened_at: date_for(created_at),
      closed_at: if(closed?, do: Timex.now, else: nil),
      merged_at: date_for(merged_at),
      title: title,
      number: number,
      html_url: html_url,
      mergeable: not String.downcase(mergeable_state) in ["dirty", "conflicting"],
      github_user: user,
      github_user_avatar: user_avatar_url,
      sha: sha
    }
    pid = Process.whereis(:"pr-#{repository}-#{number}")
    ShaMapper.register_pid(sha, pid) # Ensure sha mapper is up to date
    EventProcessor.process(:pull_request, %{"action" => "opened", "number" => number, "pull_request" => pr})

    Process.sleep(500) # Sleep to allow the front-end to subscribe before broadcasting status

    statuses
    |> Enum.each(fn %{"state" => state, "context" => context, "targetUrl" => target_url} ->
      EventProcessor.process(:status, %{"sha" => sha, "state" => String.downcase(state), "context" => context, "target_url" => target_url})
    end)
  end
  defp pr_response(response) do
    Logger.warn("Did not have all data expected. Skipping \n#{inspect response, pretty: true}")
  end

  @blame_query """
  query BlameUser($owner: String!, $name: String!, $commit: GitObjectID!, $file: String!) {
    repository(owner: $owner, name: $name) {
      object(oid: $commit) {
      	... on Commit {
        	blame(path: $file) {
            ranges {
              startingLine
              endingLine
              commit {
                author {
                  user {
                    name
                    login
                  }
                  avatarUrl
                  email
                }
              }
            }
          }
      	}
      }
    }
  }
  """
  def blame(owner, repo, sha, "./" <> file, line), do: blame(owner, repo, sha, file, line)
  def blame(owner, repo, sha, file, line) do
    query(@blame_query, %{owner: owner, name: repo, commit: sha, file: file})
    |> tap({:ok, data} ~> data)
    |> get_in(~w(data repository object blame ranges))
    |> case do
      nil -> []
      d -> d
    end
    |> Enum.find(&(&1["startingLine"] <= line && &1["endingLine"] >= line))
    |> get_in(~w(commit author))
  end
end
