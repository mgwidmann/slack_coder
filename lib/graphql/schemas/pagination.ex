defmodule SlackCoder.GraphQL.Schemas.Pagination do
  @moduledoc """
  """
  use Absinthe.Schema.Notation
  alias SlackCoder.Models.{User, RandomFailure}

  union :entries do
    @desc "Union object for all paginated things."
    types [:failure, :user]
    resolve_type fn
      %RandomFailure{}, _ -> :failure
      %User{}, _ -> :user
    end
  end

  object :pagination do
    field :total_entries, :integer, description: ""
    field :total_pages, :integer, description: ""
    field :page_number, :integer, description: ""
    field :page_size, :integer, description: ""
    field :entries, list_of(:entries)
  end
end
