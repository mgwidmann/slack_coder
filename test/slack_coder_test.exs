defmodule SlackCoderTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  describe "start" do
    let :repos do
      [
        my_repo: [owner: :bob],
        another: [owner: :jim]
      ]
    end
    before :each do
      me = self
      allow(SlackCoder.Slack) |> to_receive(start_link: fn(_, _)-> {:ok, me} end)
      allow(SlackCoder.Github.PullRequest) |> to_receive(start_link: fn(_)-> {:ok, me} end)
      allow(SlackCoder.Github.PullRequest.Watcher) |> to_receive(start_link: fn(_)-> {:ok, me} end)
      allow(Application, [:no_link, :passthrough]) |> to_receive(get_env: fn
        :slack_coder, :repos, [] ->
          repos
      end)
      on_exit fn->
        :application.stop(SlackCoder)
      end
    end

    xit "starts up one pull request per repository" do
      :application.start(SlackCoder, :temporary)
      expect SlackCoder.Github.PullRequest |> to_have_received :start_link |> with "my_repo"
      expect SlackCoder.Github.PullRequest |> to_have_received :start_link |> with "another"
    end

  end

end
