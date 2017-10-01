defmodule SlackCoder.GraphQL.InputObjects.User do
  use Absinthe.Schema.Notation

  input_object :user_input_config do
    field :open_self, :boolean
    field :close_self, :boolean
    field :fail_self, :boolean
    field :pass_self, :boolean
    field :merge_self, :boolean
    field :conflict_self, :boolean
    field :open_monitors, :boolean
    field :close_monitors, :boolean
    field :fail_monitors, :boolean
    field :pass_monitors, :boolean
    field :merge_monitors, :boolean
    field :conflict_monitors, :boolean
  end

  input_object :user_input do
    field :slack, :string
    field :name, :string
    field :admin, :boolean
    field :muted, :boolean
    field :github, :string
    field :config, :user_input_config
  end
end
