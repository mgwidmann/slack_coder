defmodule SlackCoder.PageViewTest do
  use SlackCoder.ConnCase, async: true
  alias SlackCoder.PageView
  alias SlackCoder.Models.Commit
  alias SlackCoder.Models.PR

  describe "pull_request.html" do

    it "bare minimum commit data" do
      expect {:safe, _} = PageView.render("pull_request.html", pr: %PR{latest_commit: %Commit{}, html_url: "h", title: "t"})
    end

    it "populated commit with a PR" do
      pr = %PR{latest_commit: %Commit{}, owner: "o", statuses_url: "url", repo: "r", branch: "b", github_user: "g", backoff: 1, title: "t", html_url: "h"}
      expect {:safe, _} = PageView.render("pull_request.html", pr: pr)
    end

  end
end
