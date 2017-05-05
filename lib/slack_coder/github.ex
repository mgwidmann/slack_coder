defmodule SlackCoder.Github do
  require Logger
  alias SlackCoder.Github.EventProcessor
  alias SlackCoder.Github.Watchers.Supervisor, as: PullRequestSupervisor
  alias SlackCoder.Services.UserService

  def client do
    Tentacat.Client.new(%{
      user: Application.get_env(:slack_coder, :github)[:user],
      password: Application.get_env(:slack_coder, :github)[:pat]
    })
  end

  @events ~w(commit_comment create delete deployment deployment_status download follow fork fork_apply gist
    gollum issue_comment issues label member membership milestone page_build ping public pull_request pull_request_review
    pull_request_review_comment push release repository status team team_add watch)
  def events(), do: @events

  def synchronize(owner, repository) do
    raw_prs = Tentacat.Pulls.list(owner, repository, client())
    raw_prs |> Enum.each(fn(pr)->
      pr["user"]["login"]
      |> Tentacat.Users.find(client())
      |> UserService.find_or_create_user()

      EventProcessor.process_async(:pull_request, %{"action" => "opened", "number" => pr["number"], "pull_request" => pr})
    end)
    # Look for closed PRs
    prs = PullRequestSupervisor.pull_requests() |> Map.values() |> List.flatten()
    ((prs |> Enum.map(&(&1.number))) -- (raw_prs |> Enum.map(&(&1["number"])))) |> Enum.each(fn(pr_number)->
      pr = Tentacat.Pulls.find(owner, repository, pr_number, client())
      EventProcessor.process_async(:pull_request, %{"action" => "closed", "number" => pr_number, "pull_request" => pr})
    end)
  end
end
