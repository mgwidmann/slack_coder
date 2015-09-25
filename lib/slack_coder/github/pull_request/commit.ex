defmodule SlackCoder.Github.PullRequest.Commit do
  @derive Access
  defstruct id: nil, travis_url: nil, code_climate_url: nil, status: :unkown, code_climate_status: :unknown, pr: nil, sha: nil, github_user: nil, github_user_avatar: nil
end
