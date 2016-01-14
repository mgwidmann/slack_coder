defmodule SlackCoder.PageViewTest do
  use SlackCoder.ConnCase, async: true
  alias SlackCoder.PageView
  alias SlackCoder.Models.Commit
  alias SlackCoder.Models.PR

  describe "pull_request.html" do

    it "bare minimum commit data" do
      assert {:safe, _} = PageView.render("pull_request.html", pr: %PR{latest_commit: %Commit{}, html_url: "h", title: "t"})
    end

    it "populated commit with a PR" do
      pr = %PR{latest_commit: %Commit{}, owner: "o", statuses_url: "url", repo: "r", branch: "b", github_user: "g", backoff: 1, title: "t", html_url: "h"}
      assert {:safe, _} = PageView.render("pull_request.html", pr: pr)
    end

  end

  describe "index.html" do
    let :pr, do: %SlackCoder.Models.PR{latest_commit: %SlackCoder.Models.Commit{}, number: 123, owner: "o", statuses_url: "url", repo: "r", branch: "b", github_user: "g", backoff: 1, title: "t", html_url: "h"}
    let :current_user, do: %{github: "me", monitors: ["someone"]}

    it "renders my pull requests" do
      rendered = PageView.render("index.html", prs: %{me: [pr], someone: []}, user: "me", current_user: current_user)
                 |> Phoenix.HTML.safe_to_string
      assert rendered =~ ~r/My pull requests/
      assert rendered =~ ~r/pr-123/
    end

    it "renders my monitors requests" do
      rendered = PageView.render("index.html", prs: %{me: [], someone: [pr]}, user: "me", current_user: current_user)
                 |> Phoenix.HTML.safe_to_string
      assert rendered =~ ~r/Team members I monitor/
      assert rendered =~ ~r/pr-123/
    end

    it "does not render those I don't monitor" do
      rendered = PageView.render("index.html", prs: %{me: [], someone_else: [pr]}, user: "me", current_user: current_user)
                 |> Phoenix.HTML.safe_to_string
      assert rendered =~ ~r/Team members I monitor/ # Should be there since monitors is not empty
      assert not String.contains?(rendered, "pr-123")
    end

  end

end
