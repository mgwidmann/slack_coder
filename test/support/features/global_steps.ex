defmodule SlackCoder.Features.GlobalSteps do
  use Cabbage.Feature

  defgiven ~r/^I have a user$/, _vars, state do
    {:ok, %{user: %SlackCoder.Models.User{name: "Tester", slack: "slack", github: "github"}}}
  end


  defgiven ~r/^I am logged in$/, _vars, %{session: session, user: user} do
    IO.inspect user
  end

  defand ~r/^I visit "(?<path>[^"]+)"$/, %{path: path}, %{session: session} do
    session |> visit(path)
  end

  defand ~r/^I click on the link css "(?<link_selector>[^"]+)"$/, %{link_selector: link_selector}, %{session: session} do
    click(session, css(link_selector))
    :ok
  end
end
