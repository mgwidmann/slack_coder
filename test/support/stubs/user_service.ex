defmodule SlackCoder.Stubs.UserService do
  alias SlackCoder.Models.User
  def find_or_create_user(_) do
    {:ok, %User{id: 123}}
  end
end
