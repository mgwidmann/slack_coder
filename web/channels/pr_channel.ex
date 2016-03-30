defmodule SlackCoder.PRChannel do
  use SlackCoder.Web, :channel

  def join("prs:all", %{"github" => github}, socket) do
    socket = socket
             |> assign(:current_user, SlackCoder.Users.Supervisor.user(github) |> SlackCoder.Users.User.get)
    socket = socket # Need updated socket...
             |> assign(:monitors, SlackCoder.Github.Helper.github_user_with_monitors(socket.assigns.current_user))
    {:ok, socket}
  end
  def join("prs:all", _, _socket) do
    {:error, %{"error" => "Must be signed in"}}
  end

  intercept ["pr:update", "pr:remove"]

  def handle_out(event, payload, socket) when event in ["pr:update", "pr:remove"] do
    push_if_belongs(event, payload, socket)
    {:noreply, socket}
  end

  def handle_out(event, payload, socket) do
    push socket, event, payload
    {:noreply, socket}
  end

  defp push_if_belongs(event, payload, socket) do
    if socket.assigns.current_user.github in socket.assigns.monitors do
      push socket, event, payload
    end
  end
end
