defmodule SlackCoder.PageViewTest do
  use SlackCoder.ConnCase, async: true
  alias SlackCoder.PageView
  alias SlackCoder.Models.Commit
  alias SlackCoder.Models.PR

  describe "pull_request.html" do

    it "bare minimum commit data" do
      expect {:safe, _} = PageView.render("pull_request.html", commit: %Commit{pr: %PR{html_url: "http://github.com/", title: "Github"}})
    end

    it "populated commit with a PR" do
      pr = %PR{html_url: "url", repo: "myrepo", statuses_url: "statuses", title: "MY PR", number: 4321}
      commit = %Commit{id: 123, travis_url: "travis", code_climate_url: "codeclimate", status: :success, code_climate_status: :success, pr: pr, sha: "1234", github_user: "gituser", github_user_avatar: "avatar.jpg"}
      expect {:safe, _} = PageView.render("pull_request.html", commit: commit)
    end

  end
end
