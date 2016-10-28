defmodule SlackCoder.GithubController do
  use SlackCoder.Web, :controller
  alias SlackCoder.Github.EventProcessor

  @event_header "X-GitHub-Event" |> String.downcase
  @valid_events SlackCoder.Github.events

  plug :verify_event

  def event(conn = %{assigns: %{event: event}}, params) do
    EventProcessor.process_async(event, params)
    Logger.info "Github Event: #{event}"
    conn |> text("ok")
  end

  defp verify_event(conn, _params) do
    event = get_req_header(conn, @event_header) |> List.first

    if Enum.member?(@valid_events, event) do
      conn |> assign(:event, String.to_existing_atom(event))
    else
      Logger.warn "Received invalid event: #{event}"
      conn
      |> put_status(:unprocessable_entity)
      |> text("not ok")
      |> halt
    end
  end

end
