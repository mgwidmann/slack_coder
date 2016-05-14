defmodule SlackCoder.Github.Watchers.PullRequest.Helper do
  alias SlackCoder.Github.Notification
  alias SlackCoder.Models.Commit
  alias SlackCoder.Models.PR
  alias SlackCoder.Repo
  alias SlackCoder.Services.PRService
  alias SlackCoder.Services.CommitService
  alias SlackCoder.Github
  alias Tentacat.Pulls
  alias Tentacat.Commits
  alias Tentacat.Repositories.Statuses
  import SlackCoder.Github.TimeHelper

  def status(pr) do
    if Notification.can_send_notifications? || pr.latest_commit == nil do
      me = self
      Task.start fn ->
        try do
          send(me, {:commit_results, _status(pr)})
        rescue # Rate limiting from Github causes exceptions, until a better solution
          e -> # within Tentacat presents itself, just log the exception...
            Logger.error "#{Exception.message(e)}\n#{Exception.format_stacktrace}"
        end
      end
    end
  end

  defp _status(pr) do
    pr = Pulls.find(pr.owner, pr.repo, pr.number, Github.client)
          |> build_or_update(pr)
          |> conflict_notification(pr)

    commit = (with %{} = raw_commit      <- get_latest_commit(pr),
                   {travis, codeclimate} <- statuses_for_commit(pr, raw_commit["sha"]),
                   %Commit{} = commit    <- find_latest_commit(pr, travis["id"], raw_commit["sha"]),
                   %{} = params          <- build_params(pr, raw_commit, travis, codeclimate),
                   %Commit{} = commit    <- update_commit(commit, params), do: commit)

    %PR{ pr | latest_commit: commit || pr.latest_commit}
  end

  def build_or_update(pr), do: build_or_update(pr, Repo.get_by(PR, number: pr["number"]) || %PR{})
  def build_or_update(pr, nil), do: build_or_update(pr)
  def build_or_update(pr, %PR{id: id} = existing_pr) when is_integer(id) do
    mergeable = not pr["mergeable_state"] in ["dirty"]
    {:ok, existing_pr} = PR.reg_changeset(existing_pr, %{
                           title: pr["title"],
                           closed_at: date_for(pr["closed_at"]),
                           merged_at: date_for(pr["merged_at"]),
                           mergeable: mergeable
                         })
                         |> Repo.update
    %PR{ existing_pr | github_user_avatar: pr["user"]["avatar_url"] }
  end
  def build_or_update(pr, new_pr = %PR{}) do
    repo = pr["base"]["repo"]["name"]
    owner = pr["base"]["repo"]["owner"]["login"]
    {:ok, new_pr} = new_pr
                  |> PR.reg_changeset(
                    %{number: pr["number"],
                      title: pr["title"],
                      html_url: pr["_links"]["html"]["href"],
                      statuses_url: "repos/#{owner}/#{repo}/statuses/",
                      github_user: pr["user"]["login"],
                      opened_at: date_for(pr["created_at"]),
                      closed_at: date_for(pr["closed_at"]),
                      merged_at: date_for(pr["merged_at"]),
                      owner: owner,
                      repo: repo,
                      branch: pr["head"]["ref"],
                      fork: pr["head"]["repo"]["owner"]["login"] != pr["base"]["repo"]["owner"]["login"],
                      github_user_avatar: pr["user"]["avatar_url"]
                    })
                  |> PRService.save
    new_pr
  end

  def conflict_notification(refreshed_pr, pr) do
    # Prior was mergeable but now it is not
    if pr.mergeable && refreshed_pr.mergeable == false do
      Notification.conflict(refreshed_pr)
    end

    refreshed_pr
  end

  defp get_latest_commit(pr) do
    owner = if(pr.fork, do: pr.github_user, else: pr.owner)

    Commits.filter(owner, pr.repo, %{sha: pr.branch}, Github.client)
    |> List.first
  end

  defp statuses_for_commit(_pr, nil), do: nil # 404 returned when user deletes branch
  defp statuses_for_commit(pr, sha) do
    status = Statuses.find(pr.owner, pr.repo, sha, Github.client)
    statuses = status["statuses"]

    last_status = statuses # List is already sorted, first is the latest
                  |> Enum.find(&( &1["context"] =~ ~r/travis/))
    code_climate = statuses # List is already sorted, first is the latest
                  |> Enum.find(&( &1["context"] =~ ~r/codeclimate/))

    {last_status || status["state"], code_climate}
  end

  # if pr has latest commit object use that
  defp find_latest_commit(%PR{latest_commit: commit = %Commit{latest_status_id: id}}, id, _) do
    commit
  end
  defp find_latest_commit(_, _, commit_sha) do
    # When rebooted, this commit may have already been reported on, or its new
    Repo.get_by(Commit, sha: commit_sha) || %Commit{sha: commit_sha}
  end

  @pending "pending"
  @conflict "conflict"
  defp build_params(pr, last_commit, last_status, code_climate) do
    %{
      status: if(pr.mergeable, do: last_status["state"] || @pending, else: @conflict),
      code_climate_status: code_climate["state"] || @pending,
      travis_url: last_status["target_url"],
      code_climate_url: code_climate["target_url"],
      sha: last_commit["sha"],
      github_user: last_commit["author"]["login"],
      github_user_avatar: last_commit["author"]["avatar_url"],
      latest_status_id: last_status["id"],
      pr_id: pr.id
     }
  end

  defp update_commit(commit, params) do
    {:ok, commit} = commit
                    |> Commit.changeset(params)
                    |> CommitService.save
    commit
  end
end
