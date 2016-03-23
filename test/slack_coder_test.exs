defmodule SlackCoderTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect

  before :each do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(SlackCoder.Repo)
  end

  describe "start" do
    let :repos do
      [
        my_repo: [owner: :bob],
        another: [owner: :jim]
      ]
    end
    before :each do
      allow(SlackCoder.Slack) |> to_receive(start_link: fn(_, _)-> {:ok, self()} end)
      allow(SlackCoder.Github.PullRequest) |> to_receive(start_link: fn(_)-> {:ok, self()} end)
      allow(SlackCoder.Github.PullRequest.Watcher) |> to_receive(start_link: fn(_)-> {:ok, self()} end)
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
      expect(SlackCoder.Github.PullRequest) |> to_have_received(:start_link) |> with_args("my_repo")
      expect(SlackCoder.Github.PullRequest) |> to_have_received(:start_link) |> with_args("another")
    end

  end

end
