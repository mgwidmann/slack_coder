defmodule SlackCoder.PageViewTest do
  use SlackCoder.ConnCase, async: true
  alias SlackCoder.PageView
  alias SlackCoder.Github.PullRequest.Commit
  alias SlackCoder.Github.PullRequest.PR

  describe "pull_request.html" do

    it "blank commit" do
      expect {:safe, _} = PageView.render("pull_request.html", commit: %Commit{})
    end

    it "populated commit with a PR" do
      pr = %PR{slack_user: "slack", html_url: "url", repo: "myrepo", watcher: self, commits_url: "commits", statuses_url: "statuses", title: "MY PR", number: 4321}
      commit = %Commit{id: 123, travis_url: "travis", code_climate_url: "codeclimate", status: :success, code_climate_status: :success, pr: pr, sha: "1234", github_user: "gituser", github_user_avatar: "avatar.jpg"}
      expect {:safe, _} = PageView.render("pull_request.html", commit: commit)
    end

  end
end
