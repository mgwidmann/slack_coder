defmodule SlackCoder.Slack.Helper do

  for method <- [:user, :channel, :group] do
    def unquote(method)(slack, name) when is_atom(name), do: unquote(method)(slack, to_string(name))
    def unquote(method)(slack, name) do
      slack[unquote(:"#{method}s")]
      |> Map.values
      |> Enum.find(&(&1.name == name))
    end
  end

  def im(_slack, nil), do: nil
  def im(slack, user) when is_map(user), do: im(slack, user.id)
  def im(slack, user) when is_binary(user) do
    slack[:ims]
    |> Map.values
    |> Enum.find(&(&1.user == user))
  end
end
