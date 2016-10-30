defmodule SlackCoder.UserControllerTest do
  use ExUnit.Case, async: true
  use SlackCoder.ConnCase

  alias SlackCoder.Models.User
  @valid_attrs %{slack: "slack", github: "github"}
  @invalid_attrs %{github: "only github"}

  @tag :pending
  test "renders form for new resources" do
    conn = get conn, user_path(conn, :new)
    assert html_response(conn, 200) =~ "New user"
  end

  @tag :pending
  test "creates resource and redirects when data is valid" do
    conn = post conn, user_path(conn, :create), user: @valid_attrs
    assert redirected_to(conn) == user_path(conn, :index)
    assert Repo.get_by(User, @valid_attrs)
  end

  @tag :pending
  test "does not create resource and renders errors when data is invalid" do
    conn = post conn, user_path(conn, :create), user: @invalid_attrs
    assert html_response(conn, 200) =~ "New user"
  end

  @tag :pending
  test "renders page not found when id is nonexistent" do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, user_path(conn, :show, -1)
    end
  end

  @tag :pending
  test "renders form for editing chosen resource" do
    user = Repo.insert! %User{}
    conn = get conn, user_path(conn, :edit, user)
    assert html_response(conn, 200) =~ "Edit user"
  end

  @tag :pending
  test "updates chosen resource and redirects when data is valid" do
    user = Repo.insert! %User{}
    conn = put conn, user_path(conn, :update, user), user: @valid_attrs
    assert redirected_to(conn) == user_path(conn, :show, user)
    assert Repo.get_by(User, @valid_attrs)
  end

  @tag :pending
  test "does not update chosen resource and renders errors when data is invalid" do
    user = Repo.insert! %User{}
    conn = put conn, user_path(conn, :update, user), user: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit user"
  end

end
