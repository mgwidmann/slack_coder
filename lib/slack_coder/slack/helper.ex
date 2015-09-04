defmodule SlackCoder.Slack.Helper do

  for method <- [:user, :channel, :group] do
    def unquote(method)(slack, name) when is_atom(name), do: unquote(method)(slack, to_string(name))
    def unquote(method)(slack, name) do
      slack[unquote(:"#{method}s")]
      |> Map.values
      |> Enum.find(&(&1.name == name))
    end
  end

end
