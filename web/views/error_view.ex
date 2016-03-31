defmodule SlackCoder.ErrorView do
  use SlackCoder.Web, :view

  @not_found File.cwd!
             |> Path.join("priv/static/404.html")
             |> File.read!
  def render("404.html", _assigns) do
    @not_found
  end

  @not_found File.cwd!
             |> Path.join("priv/static/500.html")
             |> File.read!
  def render("500.html", _assigns) do
    @error
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render "500.html", assigns
  end
end
