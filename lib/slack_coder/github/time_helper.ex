defmodule SlackCoder.Github.TimeHelper do
  use Timex
  
  def now do
    to_local(DateTime.local)
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
    case Timex.Date.compare(date1, date2) do
      -1 -> {:second, date2}
      0 -> {:first, date1} # Doesn't matter really
      1 -> {:first, date1}
    end
  end

  def date_for(nil), do: nil
  def date_for(string) do
     {:ok, date} = Timex.parse(string, "{ISO}")
     date
  end
end
