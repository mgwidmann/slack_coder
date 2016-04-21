defmodule SlackCoder.UserView do
  use SlackCoder.Web, :view

  def new_or_update_user_path(%Plug.Conn{path_info: ["admin" | _]} = conn, user) do
    user_path(conn, :create_external, user.github)
  end
  def new_or_update_user_path(conn, %{id: nil}) do
    user_path(conn, :create)
  end
  def new_or_update_user_path(conn, user) do
    user_path(conn, :update, user)
  end

  def keys_for_class(class) do
    class = to_string(class)

    SlackCoder.Users.Help.default_config_keys
    |> Stream.filter(&String.ends_with?(&1, class))
    |> Enum.chunk(2, 2, [nil])
  end

  def label_for("close" <> _), do: "Closed PRs"
  def label_for("conflict" <> _), do: "Merge Conflicts"
  def label_for("fail" <> _), do: "Failed Builds"
  def label_for("merge" <> _), do: "Merged PRs"
  def label_for("pass" <> _), do: "Passed Builds"
  def label_for("stale" <> _), do: "Stale PRs"
  def label_for("unstale" <> _), do: "Unstale PRs"
  def label_for(label), do: label
end
