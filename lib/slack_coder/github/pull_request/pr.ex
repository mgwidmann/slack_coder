defmodule SlackCoder.Github.PullRequest.PR do
  @derive Access
  defstruct slack_user: nil,
            html_url: nil,
            repo: nil,
            owner: nil,
            watcher: nil,
            statuses_url: nil,
            title: nil,
            number: nil,
            branch: nil,
            github_user: nil
end
