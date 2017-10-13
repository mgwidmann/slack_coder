defmodule SlackCoder.Github.EventProcessorTest do
  use SlackCoder.ChannelCase
  import ExUnit.CaptureLog
  alias SlackCoder.Github.EventProcessor, as: EP
  alias SlackCoder.Repo
  alias SlackCoder.Models.PR
  alias SlackCoder.Models.RandomFailure
  alias SlackCoder.Models.RandomFailure.FailureLog

  setup_all do
    [RandomFailure, FailureLog, PR] |> Enum.each(&Repo.delete_all/1)
    SlackCoder.Github.Watchers.Supervisor.start_link
    SlackCoder.Github.ShaMapper.start_link
    :ok
  end

  describe "push" do
  end

  describe "issue_comment" do
  end

  describe "commit_comment" do
  end

  describe "issues" do
  end

  describe "pull_request" do
    alias SlackCoder.Github.Watchers.Supervisor, as: GithubSupervisor

    setup do
      Ecto.Adapters.SQL.Sandbox.mode(SlackCoder.Repo, :manual)
      on_exit fn ->
        Ecto.Adapters.SQL.Sandbox.mode(SlackCoder.Repo, :auto)
      end
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
      pr = Repo.insert! %PR{github_user: "github_user", number: round(:rand.uniform() * 10_000), mergeable: true, sha: "before_sha", title: "t", owner: "owner", repo: "repo", branch: "b", opened_at: DateTime.utc_now, html_url: "u"}
      pid = GithubSupervisor.start_watcher(pr)
      Ecto.Adapters.SQL.Sandbox.allow(Repo, self(), pid)
      Process.sleep(20) # Allow init phase to run
      # @endpoint.subscribe("prs:all")
      on_exit fn ->
        GithubSupervisor.stop_watcher(pr)
      end
      {:ok, %{pr: pr, pr_pid: pid}}
    end

    @pr_params %{
      "title" => "title",
      "created_at" => "2017-01-01 00:00:00Z",
      "base" => %{"repo" => %{"owner" => %{"login" => "owner"}, "name" => "repo"}},
      "user" => %{"login" => "github_user"},
      "head" => %{"sha" => "after_sha", "ref" => "branch"},
      "_links" => %{"html" => %{"href" => "http://www.example.com"}},
      "mergeable_state" => "conflicting"
    }

    @tag :pending
    test "processes an open action" do
      pr_number = round(:rand.uniform() * 10_000)
      assert EP.process(:pull_request, %{"action" => "open", "pull_request" => Map.put(@pr_params, "number", pr_number), "number" => pr_number})
      assert GithubSupervisor.find_watcher(%PR{number: pr_number}) |> SlackCoder.Github.Watchers.PullRequest.fetch()
    end

    test "processes a synchronize action", %{pr: pr} do
      assert EP.process(:pull_request, %{"action" => "synchronize", "number" => pr.number, "before" => "before_sha", "after" => "after_sha", "pull_request" => Map.put(@pr_params, "number", pr.number)})
    end

    test "title is changed", %{pr: pr} do
      params = Fixtures.PRs.title_changed()
               |> put_in(~w(number), pr.number)
               |> put_in(~w(pull_request head sha), pr.sha)
               |> put_in(~w(pull_request base repo owner login), pr.owner)
               |> put_in(~w(pull_request base repo name), pr.repo)
               |> put_in(~w(pull_request number), pr.number)
      assert EP.process(:pull_request, params)
    end

    @pr_merge_conflict %{
      "action" => "synchronize",
      "before" => "before_sha",
      "after" => "after_sha",
      "pull_request" => @pr_params
    }
    test "recognizes merge conflicts", %{pr: pr, pr_pid: pid} do
      params = Map.put(@pr_merge_conflict, "number", pr.number) |> put_in(~w(pull_request number), pr.number)
      EP.process(:pull_request, params)
      updated_pr = SlackCoder.Github.Watchers.PullRequest.fetch(pid)
      refute updated_pr.mergeable
      # number = updated_pr.number
      # user = updated_pr.github_user
      # assert_broadcast("pr:update", %{pr: ^number, github: ^user, html: "<tr id=" <> _})
      Ecto.Adapters.SQL.Sandbox.checkin(Repo)
    end

    test "mergeable unknown does not change anything", %{pr: pr, pr_pid: pid} do
      params = Map.put(@pr_merge_conflict, "number", pr.number) |> put_in(~w(pull_request number), pr.number) |> put_in(~w(pull_request mergeable_state), "unknown")
      EP.process(:pull_request, params)
      updated_pr = SlackCoder.Github.Watchers.PullRequest.fetch(pid)
      assert updated_pr.mergeable
      # number = updated_pr.number
      # user = updated_pr.github_user
      # assert_broadcast("pr:update", %{pr: ^number, github: ^user, html: "<tr id=" <> _})
      Ecto.Adapters.SQL.Sandbox.checkin(Repo)
    end

    test "ignores other status changes" do
      assert capture_log(fn ->
        refute EP.process(:pull_request, %{"action" => "unknown"})
      end)
    end
  end

  describe "pull_request_review_comment" do
  end

  describe "status" do
    alias SlackCoder.Github.Watchers.Supervisor, as: GithubSupervisor
    alias SlackCoder.Github.Watchers.PullRequest
    alias SlackCoder.BuildSystem.File

    @before_sha "theshabefore"
    setup do
      [RandomFailure, FailureLog, PR] |> Enum.each(&Repo.delete_all/1)
      pr = Repo.insert! %PR{github_user: "github_user", number: round(:rand.uniform() * 10_000), mergeable: true, sha: @before_sha, title: "t", owner: "o", repo: "r", branch: "b", opened_at: DateTime.utc_now, html_url: "u"}
      pid = GithubSupervisor.start_watcher(pr)
      Ecto.Adapters.SQL.Sandbox.allow(Repo, self(), pid)
      Process.sleep(20) # Allow init phase to run
      on_exit fn ->
        GithubSupervisor.stop_watcher(pr)
      end
      {:ok, %{pr: pr, pr_pid: pid}}
    end

    @sha "anewshathatgotpushed"
    test "tracks and reports randomly failed builds", %{pr: pr, pr_pid: pid} do
      EP.process(:push, %{"before" => @before_sha, "after" => @sha})
      EP.process(:pull_request, Map.merge(Fixtures.PRs.synchronize(),
                                          %{
                                            "number" => pr.number,
                                            "before" => @before_sha,
                                            "after" => @sha
                                          })
                                          |> put_in(~w(pull_request head sha), @sha)
                                          |> put_in(~w(pull_request base repo owner login), pr.owner)
                                          |> put_in(~w(pull_request base repo name), pr.repo)
                                          |> put_in(~w(pull_request number), pr.number))
      # For realism, the status will change to pending while running the tests
      EP.process(:status, Map.merge(Fixtures.PRs.status_pending(), %{"number" => pr.number, "sha" => @sha, "target_url" => "https://travis-ci.com/#{pr.owner}/#{pr.repo}/builds/4"}))

      # Begin actual test
      EP.process(:status, Map.merge(Fixtures.PRs.status_failed(), %{"number" => pr.number, "sha" => @sha, "target_url" => "https://travis-ci.com/#{pr.owner}/#{pr.repo}/builds/4"}))
      assert %PR{build_status: "failure", last_failed_sha: @sha, last_failed_jobs: [%File{}, %File{}]} = PullRequest.fetch pid
      EP.process(:status, Map.merge(Fixtures.PRs.status_pending(), %{"number" => pr.number, "sha" => @sha, "target_url" => "https://travis-ci.com/#{pr.owner}/#{pr.repo}/builds/4"}))
      assert %PR{build_status: "pending"} = PullRequest.fetch pid
      EP.process(:status, Map.merge(Fixtures.PRs.status_success(), %{"number" => pr.number, "sha" => @sha, "target_url" => "https://travis-ci.com/#{pr.owner}/#{pr.repo}/builds/4"}))
      assert %PR{build_status: "success"} = PullRequest.fetch pid

      Process.sleep(100) # Wait for random failure service to finish processing
      number = pr.number
      [rspec_failure, cucumber_failure] = Repo.all(from(f in RandomFailure, where: f.pr == ^number, order_by: [asc: :id]))
      %FailureLog{id: rspec_failure_log_id} = rspec_log = Repo.one(Ecto.assoc(rspec_failure, :failure_log))
      %FailureLog{id: cucumber_failure_log_id} = cucumber_log = Repo.one(Ecto.assoc(cucumber_failure, :failure_log))
      pr_id = pr.id

      assert %RandomFailure{
          sha: @sha,
          failure_log_id: ^rspec_failure_log_id,
          file: "./spec/some/file.rb",
          line: "32",
          seed: 90872,
          count: 1,
          system: :travis,
          type: :rspec
        } = rspec_failure
      assert %RandomFailure{
          sha: @sha,
          failure_log_id: ^cucumber_failure_log_id,
          file: "features/some.feature",
          line: "14",
          seed: nil,
          count: 1,
          system: :travis,
          type: :cucumber
        } = cucumber_failure
      assert %FailureLog{
          pr_id: ^pr_id,
          external_id: 4,
          sha: @sha,
          log: "the really long failure log output..."
        } = rspec_log
      assert %FailureLog{
          pr_id: ^pr_id,
          external_id: 4,
          sha: @sha,
          log: "the really long failure log output..."
        } = cucumber_log
    end
  end

  describe "ping" do
  end

  describe "unknown event" do
  end
end
