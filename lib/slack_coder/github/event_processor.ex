defmodule SlackCoder.Github.EventProcessor do
  require Logger

  def process(:push, _params) do
    nil
  end
  def process(:issue_comment, _params) do
    nil
  end
  def process(:commit_comment, _params) do
    nil
  end
  def process(:issues, _params) do
    nil
  end
  def process(:pull_request, _params) do
    nil
  end
  def process(:pull_request_review_comment, _params) do
    nil
  end
  def process(:status, _params) do
    nil
  end
  def process(:ping, _params), do: nil
  def process(unknown_event, params) do
    Logger.warn "EventProcessor received unknown event #{inspect unknown_event} with params #{inspect params}"
  end
end
