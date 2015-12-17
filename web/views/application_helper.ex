defmodule SlackCoder.ApplicationHelper do
  use Phoenix.HTML
  
  def link_if(condition, opts, [do: block]) do
    if condition && opts[:to] do
      link(opts, [do: block])
    else
      content_tag :span, opts, do: block
    end
  end
end
