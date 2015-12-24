defmodule SlackCoder.UserControllerTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect
  use SlackCoder.ConnCase

  alias SlackCoder.Models.User
  @valid_attrs %{slack: "slack", github: "github"}
  @invalid_attrs %{github: "only github"}

  xit "renders form for new resources" do
    conn = get conn, user_path(conn, :new)
    assert html_response(conn, 200) =~ "New user"
  end

  xit "creates resource and redirects when data is valid" do
    conn = post conn, user_path(conn, :create), user: @valid_attrs
    assert redirected_to(conn) == user_path(conn, :index)
    assert Repo.get_by(User, @valid_attrs)
  end

  xit "does not create resource and renders errors when data is invalid" do
    conn = post conn, user_path(conn, :create), user: @invalid_attrs
    assert html_response(conn, 200) =~ "New user"
  end

  xit "renders page not found when id is nonexistent" do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, user_path(conn, :show, -1)
    end
  end

  xit "renders form for editing chosen resource" do
    user = Repo.insert! %User{}
    conn = get conn, user_path(conn, :edit, user)
    assert html_response(conn, 200) =~ "Edit user"
  end

  xit "updates chosen resource and redirects when data is valid" do
    user = Repo.insert! %User{}
    conn = put conn, user_path(conn, :update, user), user: @valid_attrs
    assert redirected_to(conn) == user_path(conn, :show, user)
    assert Repo.get_by(User, @valid_attrs)
  end

  xit "does not update chosen resource and renders errors when data is invalid" do
    user = Repo.insert! %User{}
    conn = put conn, user_path(conn, :update, user), user: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit user"
  end

end
