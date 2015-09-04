defmodule SlackCoder.Github.PullRequest.Commit do
  defstruct travis_url: nil, status: :unkown, pr: nil, sha: nil, reported_shas: HashDict.new
end
