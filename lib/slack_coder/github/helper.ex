defmodule SlackCoder.Github.Helper do
  alias SlackCoder.Github.PullRequest.PR
  alias SlackCoder.Github.PullRequest.Commit
  require Logger

  def get(url, default \\ []) do
    github_config = Application.get_env(:slack_coder, :github)
    full_url = "https://#{github_config[:user]}:#{github_config[:pat]}@api.github.com/#{url}"
    Logger.debug "HTTP Request: curl #{full_url}"
    body = case HTTPoison.get(full_url, Accept: "application/vnd.github.com.v3+json") do
             {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
               body
             {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
               response = case JSX.decode(body) do
                            {:ok, data} -> data
                            {:error, _} -> %{"message" => body}
                          end
               Logger.warn "#{full_url}\nStatus #{code}: #{response["message"]}"
               nil
             {:error, %HTTPoison.Error{reason: reason}} ->
               Logger.error "Failed to fetch: (#{reason}) #{url}"
               nil
           end
    if body do
      JSX.decode!(body)
    else
      default
    end
  end

  def pulls(repo, existing_prs \\ []) do
    me = self
    spawn_link fn->
      send(me, {:pr_response, _pulls(repo, existing_prs)})
    end
  end

  defp _pulls(repo, existing_prs) do
    users = Application.get_env(:slack_coder, :users, [])[repo]
            |> Keyword.keys
            |> Enum.map(&(to_string(&1)))
    owner = Application.get_env(:slack_coder, :repos, [])[repo][:owner]
    Logger.debug "Pulling #{owner}/#{repo} PRs with #{length(existing_prs)} existing"
    get("repos/#{owner}/#{repo}/pulls", existing_prs)
    |> Stream.filter(fn
        %PR{} = pr -> pr
        pr ->
          pr["user"]["login"] in users
      end)
    |> Stream.map(fn(pr)->
        build_pr(pr, Enum.find(existing_prs, &( &1.number == pr["number"] )))
      end)
    |> Enum.to_list
  end

  def status(commit) do
    me = self
    spawn_link fn ->
      send(me, {:commit_results, _status(commit)})
    end
  end

  defp _status(commit) do
    last_commit = (get(commit.pr.commits_url) |> List.last)["sha"]
    last_status = (commit.pr.statuses_url <> "#{last_commit}")
                  |> get
                  |> List.first # The actual status is always the first, (the rest are bogus) who knows why...
    commit = %Commit{ commit |
                status: String.to_atom(last_status["state"]),
                travis_url: last_status["target_url"],
                sha: last_commit
             }
    commit
  end

  def build_pr(pr), do: build_pr(pr, %PR{})

  def build_pr(pr, nil), do: build_pr(pr)
  def build_pr(pr, existing) do
    github_user = pr["user"]["login"] |> String.to_atom
    repo = pr["base"]["repo"]["name"] |> String.to_atom
    owner = pr["base"]["repo"]["owner"]["login"]
    slack_user = Application.get_env(:slack_coder, :users, [])[repo][github_user][:slack]
    %PR{ existing |
      number: pr["number"],
      title: pr["title"],
      html_url: pr["_links"]["html"]["href"],
      commits_url: String.replace(pr["_links"]["commits"]["href"], ~r/.*github\.com\//, ""),
      statuses_url: "repos/#{owner}/#{repo}/statuses/",
      slack_user: slack_user
    }
  end

end
