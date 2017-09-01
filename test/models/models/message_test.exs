defmodule SlackCoder.Models.MessageTest do
  use SlackCoder.ModelCase

  alias SlackCoder.Models.Message

  @valid_attrs %{message: "some content", slack: "some content", user: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Message.changeset(%Message{}, @valid_attrs)
    assert changeset.valid?
  end

  # Removed validation since we just want to capture whatever was available at the time to help debug
  @tag :pending
  test "changeset with invalid attributes" do
    changeset = Message.changeset(%Message{}, @invalid_attrs)
    refute changeset.valid?
  end
end
