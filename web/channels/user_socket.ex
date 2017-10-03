defmodule SlackCoder.UserSocket do
  use Phoenix.Socket
  use Absinthe.Phoenix.Socket

  ## Channels
  channel "graphql", SlackCoder.GraphQL

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket
  transport :longpoll, Phoenix.Transports.LongPoll

  def connect(%{"token" => token}, socket) do
    case SlackCoder.Guardian.resource_from_token(token) do
      {:ok, current_user, claims} ->
        absinthe_assigns = %{
          schema: SlackCoder.GraphQL.Schemas.MainSchema,
          opts: [
            context: %{current_user: current_user, claims: claims}
          ]
        }
        {:ok, assign(socket, :absinthe, absinthe_assigns)}
      _ ->
        :error
    end
  end
  def connect(_, _) do
    :error
  end

  def id(_socket), do: nil
end
