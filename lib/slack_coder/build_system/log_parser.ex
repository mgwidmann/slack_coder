defmodule SlackCoder.BuildSystem.LogParser do
  @moduledoc """
  Handles parsing of log files and returning a `SlackCoder.BuildSystem.Job` struct
  """
  use PatternTap
  alias SlackCoder.BuildSystem.{Job, Job.Test}

  @supported_systems ~w(rspec cucumber)a
  def parse(body) do
    results = filter_log(body)

    tests = for system <- @supported_systems do
              apply(__MODULE__, :"test_for_#{system}", [results])
            end
    %Job{
      tests: Enum.reject(tests, &match?(%Test{files: []}, &1))
    }
  end

  def test_for_rspec(results) do
    %Test{
      type: :rspec,
      seed: find_rspec_seed(results),
      files: find_rspec_failures(results)
    }
  end

  def test_for_cucumber(results) do
    %Test{
      type: :cucumber,
      files: find_cucumber_failures(results)
    }
  end

  @seed_regex ~r/Randomized with seed (?<seed>\d+)/
  defp find_rspec_seed(results) do
    results
    |> Enum.filter(&match?("Randomized with seed" <> _, &1))
    |> List.first()
    |> case do
      s when is_binary(s) ->
        seed = Regex.named_captures(@seed_regex, s)["seed"]
        {seed, _} = Integer.parse(seed)
        seed
      _ -> nil
    end
  end

  @file_line_matcher ~r/(?<file>.+?[^\[]):?(?<line>\d+|\[.+\])/
  for type <- ~w(rspec cucumber)a do
    defp unquote(:"find_#{type}_failures")(results) do
      results
      |> Stream.map(&Regex.named_captures(~r/#{unquote(type)} #{@file_line_matcher.source}.*?# (?<description>.*)/, &1))
      |> Stream.filter(&(&1))
      |> Enum.map(&({Map.fetch!(&1, "file"), Map.fetch!(&1, "line"), Map.fetch!(&1, "description")}))
    end
  end

  @line_separator if(Mix.env == :test, do: "\n", else: "\r\n")
  def filter_log(body) when is_binary(body) do
    body
    |> String.split(@line_separator)
    |> Stream.filter(&keep?/1)
    |> Enum.map(&remove_colors/1)
  end

  defp keep?("Randomized with seed" <> _), do: true
  defp keep?(unquote(IO.ANSI.red) <> "rspec ./spec" <> _), do: true
  defp keep?(unquote(IO.ANSI.red) <> "cucumber features/" <> _), do: true
  defp keep?(_line), do: false

  defp remove_colors(text), do: String.replace(text, ~r/\e\[.+?m/, "")
end
