defmodule SlackCoder.PageViewTest do
  use SlackCoder.ConnCase, async: true
  alias SlackCoder.PageView
  alias SlackCoder.Models.PR

  describe "pull_request.html" do

    test "bare minimum commit data" do
      assert {:safe, _} = PageView.render("pull_request.html", pr: %PR{html_url: "h", title: "t", number: 10})
    end

    test "populated commit with a PR" do
      pr = %PR{owner: "o", build_url: "url", repo: "r", branch: "b", github_user: "g", backoff: 1, title: "t", html_url: "h"}
      assert {:safe, _} = PageView.render("pull_request.html", pr: pr)
    end

  end

  describe "index.html" do
    @pr %SlackCoder.Models.PR{number: 123, owner: "o", build_url: "url", repo: "r", branch: "b", github_user: "g", backoff: 1, title: "t", html_url: "h"}
    @current_user %{github: "me", monitors: ["someone"]}

    test "renders my pull requests" do
      rendered = PageView.render("index.html", prs: %{me: [@pr], someone: []}, user: "me", current_user: @current_user)
                 |> Phoenix.HTML.safe_to_string
      assert rendered =~ ~r/My pull requests/
      assert rendered =~ ~r/pr-123/
    end

    test "renders my monitors requests" do
      rendered = PageView.render("index.html", prs: %{me: [], someone: [@pr]}, user: "me", current_user: @current_user)
                 |> Phoenix.HTML.safe_to_string
      assert rendered =~ ~r/Team members I monitor/
      assert rendered =~ ~r/pr-123/
    end

    test "does not render those I don't monitor" do
      rendered = PageView.render("index.html", prs: %{me: [], someone_else: [@pr]}, user: "me", current_user: @current_user)
                 |> Phoenix.HTML.safe_to_string
      assert rendered =~ ~r/Team members I monitor/ # Should be there since monitors is not empty
      assert not String.contains?(rendered, "pr-123")
    end

  end

end
