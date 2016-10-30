defmodule SlackCoder.PRChannelTest do
  use SlackCoder.ChannelCase
  alias SlackCoder.PRChannel

  test "successfully joins" do
    assert {:ok, _, _socket} = (socket("user_id", %{some: :assign})
                               |> subscribe_and_join(PRChannel, "prs:all", %{"github" => "github"}))
  end

  test "fails to join" do
    assert {:error, %{"error" => "Must be signed in"}} = (socket("user_id", %{some: :assign})
                                                         |> subscribe_and_join(PRChannel, "prs:all", %{}))
  end

end
