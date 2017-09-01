defmodule SlackCoder.GraphQL.InputObjects.User do
  use Absinthe.Schema.Notation

  input_object :user_input do
    field :slack, :string
    field :name, :string
    field :admin, :boolean
    field :muted, :boolean
    field :github, :string
  end
end
