defmodule SlackCoder.Github.PullRequest.PR do
  defstruct owner: nil, # Saved in DB
            # Holds statuses URL
            statuses_url: nil,
            # Building commit URL & saved in DB
            repo: nil,
            branch: nil,
            github_user: nil,
            # Used in view
            title: nil,
            number: nil,
            html_url: nil
end
