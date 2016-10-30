defmodule SlackCoder.Slack.HelperTest do
  use ExUnit.Case, async: true
  alias SlackCoder.Slack.Helper

  describe "user" do
    @slack %{users: %{
          "1234" => %{name: "user-1"},
          "1235" => %{name: "user-2"},
          "1236" => %{name: "user-3"},
          "1237" => %{name: "user-4"},
          "1238" => %{name: "user-5"},
        }}

    test "can find a user by string name" do
      assert Helper.user(@slack, "user-3") == %{name: "user-3"}
    end

    test "can find a user by atom name" do
      assert Helper.user(@slack, :"user-3") == %{name: "user-3"}
    end

  end

  describe "channel" do
    @slack %{channels: %{
          "1234" => %{name: "channel-1"},
          "1235" => %{name: "channel-2"},
          "1236" => %{name: "channel-3"},
          "1237" => %{name: "channel-4"},
          "1238" => %{name: "channel-5"},
        }}

    test "can find a channel by string name" do
      assert Helper.channel(@slack, "channel-3") == %{name: "channel-3"}
    end

    test "can find a channel by atom name" do
      assert Helper.channel(@slack, :"channel-3") == %{name: "channel-3"}
    end
  end

  describe "group" do
    @slack %{groups: %{
          "1234" => %{name: "group-1"},
          "1235" => %{name: "group-2"},
          "1236" => %{name: "group-3"},
          "1237" => %{name: "group-4"},
          "1238" => %{name: "group-5"},
        }}

    test "can find a group by string name" do
      assert Helper.group(@slack, "group-3") == %{name: "group-3"}
    end

    test "can find a group by atom name" do
      assert Helper.group(@slack, :"group-3") == %{name: "group-3"}
    end
  end

end
