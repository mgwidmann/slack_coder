defmodule SlackCoder.PRChannelTest do
  use SlackCoder.ChannelCase
  alias SlackCoder.PRChannel

  test "successfully joins" do
    expect {:ok, _, _socket} = (socket("user_id", %{some: :assign})
                              |> subscribe_and_join(PRChannel, "prs:all"))
  end

end
