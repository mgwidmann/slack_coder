defmodule SlackCoder.ErrorViewTest do
  use SlackCoder.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  describe "renders" do
    it "renders 404.html" do
      expect(render_to_string(SlackCoder.ErrorView, "404.html", [])) |> to_eq("Page not found")
    end

    it "render 500.html" do
      expect(render_to_string(SlackCoder.ErrorView, "500.html", [])) |> to_eq("Server internal error")
    end

    it "render any other" do
      expect(render_to_string(SlackCoder.ErrorView, "505.html", [])) |> to_eq("Server internal error")
    end
  end
end
