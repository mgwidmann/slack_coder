# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     SlackCoder.Repo.insert!(%SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

SlackCoder.Github.synchronize("weddingwire", "weddingwire-ng")
SlackCoder.Github.synchronize("weddingwire", "componets")
SlackCoder.Github.synchronize("weddingwire", "ww_constants")
SlackCoder.Github.synchronize("weddingwire", "guilds")
SlackCoder.Github.synchronize("weddingwire", "ww-contentful-cms")
SlackCoder.Github.synchronize("weddingwire", "newlywish")
SlackCoder.Github.synchronize("weddingwire", "weddingwire-android")
SlackCoder.Github.synchronize("weddingwire", "weddingwire-ios")
SlackCoder.Github.synchronize("weddingwire", "sem-catalog")
SlackCoder.Github.synchronize("weddingwire", "utils-android")
SlackCoder.Github.synchronize("weddingwire", "vendor-reviews-android")
SlackCoder.Github.synchronize("weddingwire", "weddingwire_api")
SlackCoder.Github.synchronize("weddingwire", "weddingwire-vendor-android")

require Logger
for {owner, type} <- [mgwidmann: :users] do
  apply(Tentacat.Repositories, :"list_#{type}", [owner, SlackCoder.Github.client])
  |> Enum.map(fn
    %{"name" => name} -> name
    {_status, _data} ->
      Logger.warn "Unable to fetch data for #{owner}"
      nil
  end)
  |> Enum.filter(&(&1))
  |> Enum.each(fn repo ->
    Logger.info "SlackCoder.Github.synchronize #{inspect to_string(owner)}, #{inspect repo}"
    SlackCoder.Github.synchronize(to_string(owner), repo)
  end)
end
