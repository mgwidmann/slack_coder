defmodule SlackCoder.Stubs.Users.User do
  alias SlackCoder.Models.User

  def get(_pid) do
    %User{github: "github_user", slack: "slack_user"}
  end

  def update(_pid, user) do
    user
  end

  def help(_pid, _message) do
    # Don't need to return anything
  end

  def notification(_pid, _notification) do
    # Don't need to return anything
  end
end
