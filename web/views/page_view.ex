defmodule SlackCoder.PageView do
  use SlackCoder.Web, :view

  def staleness(%PR{latest_comment: comment}) do
    SlackCoder.Github.TimeHelper.duration_diff(comment)
  end

  def render("pull_request.json", %{pr: pr}) do
    %{
      id: pr.id
    }
  end

end
