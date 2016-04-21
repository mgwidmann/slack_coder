defmodule SlackCoder.Users.Help do

  @message_types [:stale, :unstale, :fail, :pass, :close, :merge, :conflict]
  @message_classes [:self, :monitors, :callouts]
  @zipped_message_types for config <- @message_types, type <- @message_classes, do: [config, type]
  @help_text """
  _Heres a list of things that might help_

  *Commands*
  help <command>
  _More to come..._

  *Config*
  #{@zipped_message_types |> Enum.map(fn([config, type])-> "config #{config} #{type} <on/off>" end) |>Enum.join("\n")}
  """
  @unknown_message "I'm sorry. I'm too dumb to comprehend what you mean. :disappointed:"
  def handle_message(["help" | _command], config) do
    {config, @help_text}
  end
  def handle_message(["config" | settings_list], config) do
    settings(settings_list, config)
  end
  def handle_message(_, config) do
    {config, @unknown_message}
  end

  for [config, self_or_monitors] <- @zipped_message_types do
    {config, self_or_monitors} = {to_string(config), to_string(self_or_monitors)}
    defp settings([unquote(config), unquote(self_or_monitors), value], config) do
      bool_value = SlackCoder.Models.Types.Boolean.value_to_boolean(value)
      config = Map.put(config, [unquote(config), unquote(self_or_monitors)]
               |> List.flatten
               |> Enum.join("_"), bool_value)
      {config, settings_reply(unquote(config), unquote(self_or_monitors), bool_value)}
    end
    defp settings([unquote(self_or_monitors), unquote(config), value], config) do
      bool_value = SlackCoder.Models.Types.Boolean.value_to_boolean(value)
      config = Map.put(config, [unquote(config), unquote(self_or_monitors)]
               |> List.flatten
               |> Enum.join("_"), bool_value)
      {config, settings_reply(unquote(config), unquote(self_or_monitors), bool_value)}
    end
  end
  defp settings(_, config) do
    {config, "Don't think thats a configuration setting, try `help` to get more info"}
  end

  @static_config %{}
  @default_config Enum.into(Enum.map(@zipped_message_types, &({Enum.join(&1, "_"), true})), @static_config)
  def default_config(), do: @default_config

  @default_config_keys Map.keys(@default_config)
  def default_config_keys(), do: @default_config_keys

  def message_classes(), do: @message_classes
  def message_types(), do: @message_types

  defp config_for_reply("unstale"), do: "Unstale PR notifications"
  defp config_for_reply("stale"), do: "Stale PR notifications"
  defp config_for_reply("fail"), do: "Build failure notifications"
  defp config_for_reply("pass"), do: "Build success notifications"
  defp config_for_reply("close"), do: "PR close notifications"
  defp config_for_reply("merge"), do: "PR merge notifications"
  defp config_for_reply("conflict"), do: "PR conflict notifications"

  defp turned_to(true), do: "turned on"
  defp turned_to(false), do: "turned off"

  defp for_who("self"), do: "for your PRs"
  defp for_who("monitors"), do: "for your team members you monitor"
  defp for_who("callouts"), do: "for PRs you're called out on"

  defp settings_reply(config, who, value), do: "#{config_for_reply(config)} #{for_who(who)} has been #{turned_to(value)}"

end
