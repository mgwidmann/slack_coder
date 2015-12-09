defmodule SlackCoder.Users.Help do
  alias SlackCode.Slack

  @help_text """

  """
  def handle_message(["help"], user) do
    Slack.send_to(user.slack, @help_text)
    user
  end
  def handle_message(["config" | settings], user) do
    user
  end

  # def settings(["stale", "on"], user) do
  #   config = Map.put(config, "stale")
  # end
end
