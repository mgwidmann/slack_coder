defmodule SlackCoder.GraphQL.Schemas.Scalars do
  use Absinthe.Schema.Notation

  @desc """
  The `DateTime` scalar type represents time values provided in the ISO
  datetime format (that is, the ISO 8601 format without the timezone offset, eg,
  `"2015-06-24 04:50:34"`).
  """
  scalar :datetime, description: "ISO time" do
    parse &Ecto.DateTime.cast/1
    serialize &Ecto.DateTime.to_string/1
  end
end
