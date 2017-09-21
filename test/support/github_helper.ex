defmodule SlackCoder.Support.Github do
  alias SlackCoder.Models.PR
  def pr_with(data) do
    Map.merge(%PR{owner: "o", repo: "r", branch: "b", github_user: "g", title: "t", number: 1, html_url: "h", opened_at: DateTime.utc_now()}, data)
  end
end
