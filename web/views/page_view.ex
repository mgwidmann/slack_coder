defmodule SlackCoder.PageView do
  use SlackCoder.Web, :view

  def status_class(:success), do: :success
  def status_class(:failed), do: :danger
  def status_class(:pending), do: :warning
  def status_class(_), do: :default

end
