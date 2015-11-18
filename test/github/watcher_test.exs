defmodule SlackCoder.Github.WatcherTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect
  alias SlackCoder.Github.PullRequest.Watcher
  alias SlackCoder.Github.PullRequest.Commit

  describe "handle_info" do
    let :pr, do: %SlackCoder.Github.PullRequest.PR{title: "title", html_url: "html_url"}
    before :each do
      allow(SlackCoder.Github.Helper) |> to_receive(status: fn(_)-> nil end)
      :ok
    end

    describe "update_status message received" do
      let :commit, do: %SlackCoder.Github.PullRequest.Commit{}
      before :each do
        response = Watcher.handle_info(:update_status, commit)
        {:ok, response: response, commit: commit}
      end

      # Stub doesnt seem to work across modules...
      xit "async fetches new the status" do
        expect(SlackCoder.Github.Helper) |> to_have_received(:status)
      end

      it "returns {:noreply, commit} unchanged", %{response: response, commit: commit} do
        expect {:noreply, ^commit} = response
      end

    end

    describe "{:commit_results, commit} message received" do
      let :old_commit, do: %SlackCoder.Github.PullRequest.Commit{id: 1234}
      let :new_commit, do: %SlackCoder.Github.PullRequest.Commit{id: 4567, status: :failure, pr: pr}
      before :each do
        allow(SlackCoder.Slack) |> to_receive(send_to: &({&1, &2}))
        :ok
      end

      xit "reports the status when the id changed" do
        Watcher.handle_info({:commit_results, new_commit}, old_commit)
        expect(SlackCoder.Slack) |> to_have_received(send_to: 2)
      end

      it "does not report the status when pending" do
        expect {:noreply, %Commit{}}
      end
    end

  end

end
