defmodule SlackCoder.PRChannel do
  use SlackCoder.Web, :channel

  def join("prs:all", %{"github" => github}, socket) do
    assign(socket, :current_user, SlackCoder.Users.Supervisor.user(github) |> SlackCoder.Users.User.get)
    {:ok, socket}
  end
  def join("prs:all", _, socket) do
    {:error, %{"error" => "Must be signed in"}, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  # def handle_in("ping", payload, socket) do
  #   {:reply, {:ok, payload}, socket}
  # end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (prs:lobby).
  # def handle_in("shout", payload, socket) do
  #   broadcast socket, "shout", payload
  #   {:noreply, socket}
  # end

  # This is invoked every time a notification is being broadcast
  # to the client. The default implementation is just to push it
  # downstream but one could filter or change the event.
  def handle_out(event, payload, socket) do
    push socket, event, payload
    {:noreply, socket}
  end

end
