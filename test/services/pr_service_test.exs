defmodule SlackCoder.Models.PrServiceTest do
  use ExUnit.Case, async: true
  alias SlackCoder.Models.PR
  alias SlackCoder.Services.PRService

  describe "#next_backoff" do
    test "of start" do
      assert 4 == PRService.next_backoff(2, 2)
    end

    test "an hour past" do
      assert 4 == PRService.next_backoff(2, 3)
    end

    test "two hours past" do
      assert 8 == PRService.next_backoff(2, 4)
    end
  end

  describe "clearing last_failed_jobs" do
    test "when the sha changes" do
      cs = PR.reg_changeset(SlackCoder.Support.Github.pr_with(%{sha: "original", last_failed_jobs: [1,2,3], last_failed_sha: "original"}), %{sha: "newsha"})
      assert %Ecto.Changeset{changes: %{last_failed_sha: nil, last_failed_jobs: []}} = PRService.random_failure(cs)
    end

    test "when the sha does not change" do
      cs = PR.reg_changeset(SlackCoder.Support.Github.pr_with(%{sha: "original", last_failed_jobs: [1,2,3], last_failed_sha: "original", build_status: "failure"}), %{build_status: "success"})
      cs = PRService.random_failure(cs)
      assert %{build_status: "success"} == cs.changes
    end
  end
end
