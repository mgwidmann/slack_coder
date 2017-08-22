defmodule SlackCoder.Github.EventProcessorTest do
  use SlackCoder.ChannelCase
  import ExUnit.CaptureLog
  alias SlackCoder.Github.EventProcessor, as: EP
  alias SlackCoder.Repo

  setup_all do
    SlackCoder.Github.Watchers.Supervisor.start_link
    SlackCoder.Github.ShaMapper.start_link
    Ecto.Adapters.SQL.Sandbox.mode(SlackCoder.Repo, :manual)
    on_exit fn ->
      Ecto.Adapters.SQL.Sandbox.mode(SlackCoder.Repo, :auto)
    end
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
    alias SlackCoder.Models.PR

    setup do
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
      pr = Repo.insert! %PR{github_user: "github_user", number: round(:rand.uniform() * 10_000), mergeable: true, sha: "before_sha", title: "t", owner: "o", repo: "r", branch: "b", opened_at: DateTime.utc_now, html_url: "u"}
      pid = GithubSupervisor.start_watcher(pr)
      Ecto.Adapters.SQL.Sandbox.allow(Repo, self(), pid)
      @endpoint.subscribe("prs:all")
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
      assert EP.process(:pull_request, %{"action" => "synchronize", "number" => pr.number, "before" => "before_sha", "after" => "after_sha"})
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
      number = updated_pr.number
      user = updated_pr.github_user
      assert_broadcast("pr:update", %{pr: ^number, github: ^user, html: "<tr id=" <> _})
      Ecto.Adapters.SQL.Sandbox.checkin(Repo)
    end

    test "mergeable unknown does not change anything", %{pr: pr, pr_pid: pid} do
      params = Map.put(@pr_merge_conflict, "number", pr.number) |> put_in(~w(pull_request number), pr.number) |> put_in(~w(pull_request mergeable_state), "unknown")
      EP.process(:pull_request, params)
      updated_pr = SlackCoder.Github.Watchers.PullRequest.fetch(pid)
      assert updated_pr.mergeable
      number = updated_pr.number
      user = updated_pr.github_user
      assert_broadcast("pr:update", %{pr: ^number, github: ^user, html: "<tr id=" <> _})
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
  end

  describe "ping" do
  end

  describe "unknown event" do
  end
end
