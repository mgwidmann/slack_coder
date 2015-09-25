defmodule SlackCoder.PRChannelTest do
  use SlackCoder.ChannelCase
  alias SlackCoder.PRChannel

  describe "joining" do

    it "successfully joins" do
      expect {:ok, _, socket} = (socket("user_id", %{some: :assign})
                                |> subscribe_and_join(PRChannel, "prs:lobby"))
    end
    
  end

end
