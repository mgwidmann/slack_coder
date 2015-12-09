defmodule SlackCoder.Models.User.Config do

  def stale_self(user) do
    user.config["stale"]["self"]
  end
  def stale_monitors(user) do
    user.config["stale"]["monitors"]
  end
  def build_self(user) do
    user.config["build"]["self"]
  end
  def build_monitors(user) do
    user.config["build"]["monitors"]
  end
end
