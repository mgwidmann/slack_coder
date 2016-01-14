defmodule SlackCoder.PRChannelTest do
  use SlackCoder.ChannelCase
  alias SlackCoder.PRChannel

  before :each do
    allow(SlackCoder.Users.Supervisor) |> to_receive(user: fn(github)-> self end)
    allow(SlackCoder.Users.User) |> to_receive(get: fn(_pid)-> %{} end)
    :ok
  end

  it "successfully joins" do
    expect {:ok, _, _socket} = (socket("user_id", %{some: :assign})
                              |> subscribe_and_join(PRChannel, "prs:all", %{"github" => "github"}))
  end

  it "fails to join" do
    expect {:error, %{"error" => "Must be signed in"}} = (socket("user_id", %{some: :assign})
                                                         |> subscribe_and_join(PRChannel, "prs:all", %{}))
  end

end
