defmodule SlackCoder.GraphQL.Schemas.Scalars do
  use Absinthe.Schema.Notation

  @desc """
  The `DateTime` scalar type represents time values provided in the ISO
  datetime format (that is, the ISO 8601 format without the timezone offset, eg,
  `"2015-06-24T04:50:34.556675Z"`).
  """
  scalar :datetime, description: "ISO time" do
    parse fn string ->
      DateTime.from_iso8601(string)
    end
    serialize fn
      %NaiveDateTime{} = datetime ->
        datetime
        |> DateTime.from_naive!("Etc/UTC")
        |> DateTime.to_iso8601()
      %DateTime{} = datetime ->
        DateTime.to_iso8601(datetime)
      nil ->
        nil
    end
  end
end
