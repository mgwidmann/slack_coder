defmodule SlackCoder.Github.PullRequest.PR do
  @derive Access
  defstruct slack_user: nil, html_url: nil, repo: nil, watcher: nil, commits_url: nil, statuses_url: nil, title: nil, number: nil
end
