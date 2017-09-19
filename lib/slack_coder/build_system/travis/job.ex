defmodule SlackCoder.BuildSystem.Travis.Job do
  use HTTPoison.Base

  def new(results) do
    seed = find_seed(results)
    rspec_seed = Enum.at(seed, 0) # Safe indexing in case theres nothing here
    cucumber_seed = Enum.at(seed, 1)
    %SlackCoder.BuildSystem.Job{
      rspec_seed: rspec_seed,
      rspec: find_rspec_failures(results),
      cucumber_seed: cucumber_seed,
      cucumber: find_cucumber_failures(results)
    }
  end

  defp process_url(url) do
    "https://api.travis-ci.com" <> url
  end

  defp process_response_body(body) do
    body
  end

  defp process_request_headers(headers) do
    token = Application.get_env(:slack_coder, :travis_token)
    [{"Authorization", "token #{token}"} | headers]
  end

  @seed_regex ~r/Randomized with seed (?<seed>\d+)/
  defp find_seed(results) do
    results
    |> Stream.filter(&match?("Randomized with seed" <> _, &1))
    |> Stream.map(fn seed ->
      case seed do
        s when is_binary(s) -> Regex.named_captures(@seed_regex, s)["seed"]
        _ -> nil
      end
    end)
    |> Enum.to_list()
  end

  @file_line_matcher ~r/(?<file>.+?[^\[]):?(?<line>\d+|\[.+\])/
  for type <- ~w(rspec cucumber) do
    defp unquote(:"find_#{type}_failures")(results) do
      results
      |> Stream.map(&Regex.named_captures(~r/#{unquote(type)} #{@file_line_matcher.source}(#{Regex.escape IO.ANSI.light_black} # )?(?<description>.*)/, &1))
      |> Stream.filter(&(&1))
      |> Enum.map(&({Map.fetch!(&1, "file"), Map.fetch!(&1, "line"), Map.fetch!(&1, "description")}))
    end
  end

  def filter_log(body) when is_binary(body) do
    body
    |> String.split("\r\n")
    |> Stream.filter(&keep?/1)
    |> Stream.map(&remove_colors/1)
    |> Enum.map(&remove_comments/1)
  end

  defp keep?("Randomized with seed" <> _), do: true
  defp keep?(unquote(IO.ANSI.red) <> "rspec ./spec" <> _), do: true
  defp keep?(unquote(IO.ANSI.red) <> "cucumber features/" <> _), do: true
  defp keep?(_), do: false

  defp remove_colors(text), do: String.replace(text, ~r/\e\[.+?m/, "")

  defp remove_comments(text), do: String.replace(text, ~r/ #.*$/, "")
end
