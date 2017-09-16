defmodule SlackCoder.GraphQL.Resolvers.PRResolver do
  alias SlackCoder.Models.PR

  def build_status(%PR{build_status: status}) when is_binary(status) do
    String.to_atom(status)
  end
  def build_status(_), do: nil

  def analysis_status(%PR{analysis_status: status}) when is_binary(status) do
    String.to_atom(status)
  end
  def analysis_status(_), do: nil
end
