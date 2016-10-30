defmodule SlackCoder.Github do
  require Logger

  def client do
    Tentacat.Client.new(%{
      user: Application.get_env(:slack_coder, :github)[:user],
      password: Application.get_env(:slack_coder, :github)[:pat]
    })
  end

  @events ~w(commit_comment create delete deployment deployment_status download follow fork fork_apply gist
    gollum issue_comment issues label member membership milestone page_build ping public pull_request pull_request_review
    pull_request_review_comment push release repository status team_add watch)
  def events(), do: @events
end
