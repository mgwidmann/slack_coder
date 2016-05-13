defmodule SlackCoder.Stubs.Users.Supervisor do
  alias SlackCoder.Models.User

  def users do
    []
  end

  def user(_slack_user) do
    self
  end

end
