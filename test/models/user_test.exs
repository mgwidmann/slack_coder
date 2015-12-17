defmodule SlackCoder.UserTest do
  use SlackCoder.ModelCase

  alias SlackCoder.Models.User

  @valid_attrs %{config: %{}, github: "github", slack: "slack"}
  @invalid_attrs %{slack: "only slack"}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
