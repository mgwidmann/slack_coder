defmodule SlackCoder.UserView do
  use SlackCoder.Web, :view
  import Scrivener.HTML

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

  def label_for("open" <> _), do: "Open PRs"
  def label_for("close" <> _), do: "Closed PRs"
  def label_for("conflict" <> _), do: "Merge Conflicts"
  def label_for("fail" <> _), do: "Failed Builds"
  def label_for("merge" <> _), do: "Merged PRs"
  def label_for("pass" <> _), do: "Passed Builds"
  def label_for("stale" <> _), do: "Stale PRs"
  def label_for("unstale" <> _), do: "Unstale PRs"
  def label_for(label), do: label

  def render("graphql_user.json", %{user: user}) do
    %{
      id: to_string(user.id),
      slack: user.slack,
      github: user.github,
      avatarUrl: user.avatar_url,
      htmlUrl: user.html_url,
      name: user.name,
      monitors: Enum.map(user.monitors, &(%{github: &1})),
      muted: user.muted,
      admin: user.admin
    }
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      slack: user.slack,
      github: user.github,
      avatar_url: user.avatar_url,
      html_url: user.html_url,
      name: user.name,
      monitors: user.monitors,
      muted: user.muted,
      admin: user.admin
    }
  end
end
