defmodule SlackCoder.ErrorViewTest do
  use SlackCoder.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  describe "renders" do
    test "renders 404.html" do
      assert render_to_string(SlackCoder.ErrorView, "404.html", []) =~ ~r/404 Not Found/
    end

    test "render 500.html" do
      assert render_to_string(SlackCoder.ErrorView, "500.html", []) =~ ~r/500 That's broken/
    end

    test "render any other" do
      assert render_to_string(SlackCoder.ErrorView, "505.html", []) =~ ~r/500 That's broken/
    end
  end
end
