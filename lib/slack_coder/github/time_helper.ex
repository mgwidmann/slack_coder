defmodule SlackCoder.Github.TimeHelper do
  use Timex

  def now do
    to_local(Timex.local)
  end

  def to_local(date) do
    timezone = Application.get_env(:slack_coder, :timezone)
    if Timezone.exists?(timezone) && date do
      date |> Timezone.convert(timezone)
    else
      date
    end
  end

  def greatest_date_for(nil, date), do: {:second, date_for(date)}
  def greatest_date_for(date, nil), do: {:first, date_for(date)}
  def greatest_date_for(date1, date2) do
    date1 = date_for(date1)
    date2 = date_for(date2)
    case Timex.compare(date1, date2) do
      -1 -> {:second, date2}
      0 -> {:first, date1} # Doesn't matter really
      1 -> {:first, date1}
    end
  end

  def date_for(nil), do: nil
  def date_for(string) do
     {:ok, date} = Timex.parse(string, "{ISO:Extended:Z}")
     date
  end

  def duration_diff(nil), do: "Unknown Duration"
  def duration_diff(datetime) do
    datetime
    |> Timex.to_unix()
    |> Duration.from_seconds()
    |> Duration.diff(Duration.now, :seconds)
    |> Duration.from_seconds()
    |> Timex.format_duration(:humanized)
  end
end
