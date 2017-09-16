defmodule SlackCoder.GraphQL.Schemas.Scalars do
  use Absinthe.Schema.Notation

  @desc """
  The `DateTime` scalar type represents time values provided in the ISO
  datetime format (that is, the ISO 8601 format without the timezone offset, eg,
  `"2015-06-24 04:50:34"`).
  """
  scalar :datetime, description: "ISO time" do
    parse fn string ->
      DateTime.from_iso8601(string)
    end
    serialize fn datetime ->
      DateTime.to_iso8601(datetime)
    end
  end
end
