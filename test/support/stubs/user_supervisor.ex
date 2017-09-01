defmodule SlackCoder.Stubs.Users.Supervisor do

  def users do
    []
  end

  def user(_slack_user) do
    self()
  end

end
