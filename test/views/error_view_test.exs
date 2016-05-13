defmodule SlackCoder.ErrorViewTest do
  use SlackCoder.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  describe "renders" do
    it "renders 404.html" do
      expect(render_to_string(SlackCoder.ErrorView, "404.html", [])) |> to_include("404 Not Found")
    end

    it "render 500.html" do
      expect(render_to_string(SlackCoder.ErrorView, "500.html", [])) |> to_include("500 That&#39;s broken")
    end

    it "render any other" do
      expect(render_to_string(SlackCoder.ErrorView, "505.html", [])) |> to_include("500 That&#39;s broken")
    end
  end
end
