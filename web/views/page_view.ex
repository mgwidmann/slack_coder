defmodule SlackCoder.PageView do
  use SlackCoder.Web, :view

  def status_class(:success), do: :success
  def status_class(:failed), do: :danger
  def status_class(:pending), do: :warning
  def status_class(:error), do: :danger
  def status_class(_), do: :default

  def link_if(opts, [do: block]) do
    if opts[:to] do
      link(opts, [do: block])
    else
      content_tag :span, opts, do: block
    end
  end

end
