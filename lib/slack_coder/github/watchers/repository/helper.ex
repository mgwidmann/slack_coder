# defmodule SlackCoder.Github.Watchers.Repository.Helper do
  # use Timex
  # import StubAlias
  # alias SlackCoder.Repo
  # alias Tentacat.Pulls
  # stub_alias Tentacat.Issues.Comments, as: IssueComments
  # stub_alias Tentacat.Pulls.Comments, as: PullComments
  # stub_alias SlackCoder.Github.Supervisor, as: GithubSupervisor
  # alias SlackCoder.Models.{PR, User}
  # alias SlackCoder.{Github, Github.Notification, Github.Watchers.PullRequest.Helper}
  # import SlackCoder.Github.TimeHelper
  # import Ecto.Changeset, only: [put_change: 3, get_change: 2]
  # require Logger
  #
  # def pulls(repo, existing_prs \\ []) do
  #   me = self
  #   Task.start fn->
  #     try do
  #       send(me, {:pr_response, _pulls(repo, existing_prs)})
  #     rescue # Rate limiting from Github causes exceptions, until a better solution
  #       _ -> # within Tentacat presents itself, just log the exception...
  #         # Logger.error "Error updating Repository info: #{Exception.message(e)}\n#{Exception.format_stacktrace}"
  #         nil
  #     end
  #   end
  # end
  #
  # defp _pulls(repo, existing_prs) do
  #   users = Repo.all(User)
  #           |> Enum.map(&(&1.github))
  #   owner = Application.get_env(:slack_coder, :repos, [])[repo][:owner]
  #
  #   with prs when is_list(prs) <- Pulls.list(owner, repo, Github.client) do
  #     Stream.filter(prs, fn pr ->
  #         pr["user"]["login"] in users
  #     end)
  #     |> Stream.map(fn(pr)->
  #         Helper.build_or_update(pr, Enum.find(existing_prs, &( &1.number == pr["number"] )))
  #       end)
  #     |> Enum.to_list
  #   else
  #     {status, response} ->
  #       Logger.warn "Unable to fetch new pull requests, #{status} #{inspect response}"
  #       existing_prs
  #   end
  # end
  #
  # def find_latest_comment_date(%PR{number: number, repo: repo, owner: owner} = pr) do
  #   with  latest_issue_comment when is_map(latest_issue_comment) <- IssueComments.list(owner, repo, number, Github.client) |> List.last,
  #         latest_pr_comment when is_map(latest_pr_comment)       <- PullComments.list(owner, repo, number, Github.client) |> List.last do
  #     case greatest_(latest_issue_comment["updated_at"], latest_pr_comment["updated_at"]) do
  #       {:first, date} ->
  #         %{latest_comment: date || pr.opened_at, latest_comment_url: latest_issue_comment["html_url"]}
  #       {:second, date} ->
  #         %{latest_comment: date || pr.opened_at, latest_comment_url: latest_pr_comment["html_url"]}
  #     end
  #   else
  #     {status, response} ->
  #       Logger.warn "Unable to fetch latest comment date for PR #{number}, #{status} #{inspect response}"
  #       pr.opened_at
  #   end
  # end

  # def handle_closed_pr(changeset = %Ecto.Changeset{}, []), do: changeset
  # def handle_closed_pr(changeset = %Ecto.Changeset{}, old_prs) when is_list(old_prs) do
  #   old_prs
  #   |> Enum.find(&( &1.number == changeset.data.number))
  #   |> _handle_closed_pr(changeset)
  # end
  #
  # defp _handle_closed_pr(nil, cs), do: cs
  # defp _handle_closed_pr(pr = %PR{}, cs = %Ecto.Changeset{changes: %{merged_at: merged}}) when not is_nil(merged) do
  #   cleanup_pr(pr)
  #
  #   cs
  #   |> put_change(:notifications, [:merged | cs.changes[:notifications] || cs.data.notifications])
  # end
  # defp _handle_closed_pr(pr = %PR{}, cs = %Ecto.Changeset{changes: %{closed_at: closed}}) when not is_nil(closed) do
  #   cleanup_pr(pr)
  #
  #   cs
  #   |> put_change(:notifications, [:closed | cs.changes[:notifications] || cs.data.notifications])
  # end
  # defp _handle_closed_pr(_, cs), do: cs
  #
  # defp cleanup_pr(pr) do
  #   GithubSupervisor.stop_watcher(pr)
  #   SlackCoder.Endpoint.broadcast("prs:all", "pr:remove", %{pr: pr.number})
  # end

  # def build_changeset(params, pr) do
  #   PR.reg_changeset(pr, params)
  # end
  #
  # def update_pr(cs) do
  #   {:ok, pr} = SlackCoder.Services.PRService.save(cs)
  #   pr
  # end



# end
