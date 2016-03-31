defmodule SlackCoder.ErrorView do
  use SlackCoder.Web, :view

  def render("404.html", _assigns) do
    File.read!("priv/static/404.html")
  end

  def render("500.html", _assigns) do
    File.read!("priv/static/500.html")
  end

  # In case no render clause matches or no
  # template is found, let's render it as 500
  def template_not_found(_template, assigns) do
    render "500.html", assigns
  end
end
