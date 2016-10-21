defmodule SlackCoder.PageView do
  use SlackCoder.Web, :view

  def status_class(status) when is_binary(status), do: status_class(String.to_existing_atom(status))
  def status_class(:success), do: :success
  def status_class(:failed), do: :danger
  def status_class(:pending), do: :warning
  def status_class(:error), do: :danger
  def status_class(:conflict), do: :highlight

  def staleness(pr) do
    timestamp = Timex.Date.diff(pr.latest_comment, SlackCoder.Github.TimeHelper.now, :timestamp)
    Timex.Format.Time.Formatters.Humanized.format(timestamp)
  end

  def github(nil, _user), do: nil
  def github(current_user, user) do
    user && String.to_atom(user) || String.to_atom(current_user.github)
  end

end
