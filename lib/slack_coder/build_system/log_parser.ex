defmodule SlackCoder.BuildSystem.LogParser do
  @moduledoc """
  Handles parsing of log files and returning a `SlackCoder.BuildSystem.File` struct
  """
  use PatternTap
  alias SlackCoder.BuildSystem.File

  @supported_systems ~w(minitest rspec cucumber)a
  def parse(body) do
    results = filter_log(body)

    for system <- @supported_systems do
      apply(__MODULE__, :"test_for_#{system}", [results])
    end
    |> List.flatten()
    |> Enum.uniq()
  end

  def test_for_minitest(results) do
    seed = find_minitest_seed(results)
    results
    |> find_minitest_failures()
    |> Enum.map(fn file ->
      %File{type: :minitest, seed: seed, file: file}
    end)
  end

  def test_for_rspec(results) do
    seed = find_rspec_seed(results)
    results
    |> find_rspec_failures()
    |> Enum.map(fn file ->
      %File{type: :rspec, seed: seed, file: file}
    end)
  end

  def test_for_cucumber(results) do
    results
    |> find_cucumber_failures()
    |> Enum.map(fn file ->
      %File{type: :cucumber, file: file}
    end)
  end

  @seed_regex ~r/Run options: .*?--seed (?<seed>\d+).*?/
  defp find_minitest_seed(results) do
    results
    |> Enum.filter(&match?("Run options:" <> _, &1))
    |> List.first()
    |> case do
      s when is_binary(s) ->
        seed = Regex.named_captures(@seed_regex, s)["seed"]
        {seed, _} = Integer.parse(seed)
        seed
      _ -> nil
    end
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

  @file_line_matcher ~r/(?<file>.+[^\[\d])(?<line>:\d+|\[.+\])/
  for type <- ~w(rspec cucumber)a do
    defp unquote(:"find_#{type}_failures")(results) do
      results
      |> Stream.map(&Regex.named_captures(~r/#{unquote(type)} #{@file_line_matcher.source}.*?# (?<description>.*)/, &1))
      |> Stream.filter(&(&1))
      |> Enum.map(&({Map.fetch!(&1, "file"), fix_line(Map.fetch!(&1, "line")), Map.fetch!(&1, "description")}))
    end
  end

  defp find_minitest_failures(results) do
    results
    |> Enum.reverse() # Finding in reverse makes it easier to get description
    |> find_minitest_failure([])
  end

  defp find_minitest_failure([], acc), do: acc
  defp find_minitest_failure(["bin/rails test " <> file_line | rest], acc) do
    %{"file" => file, "line" => line} = Regex.named_captures(@file_line_matcher, file_line)
    error_index = Enum.find_index(rest, &match?("Error:", &1)) || 0
    ["Error:", description, _error_message | _stack] = Enum.slice(rest, 0, error_index + 1) |> Enum.reverse()
    description = String.trim_trailing(description, ":")
    find_minitest_failure(rest, [{file, fix_line(line), description} | acc])
  end
  defp find_minitest_failure([_|rest], acc), do: find_minitest_failure(rest, acc)

  defp fix_line(":" <> line), do: line
  defp fix_line(line), do: line

  @line_separator if(Mix.env == :test, do: "\n", else: "\r\n")
  def filter_log(body) when is_binary(body) do
    body
    |> String.split(@line_separator)
    |> drop_unnecessary([], false)
    |> Enum.map(&remove_colors/1)
  end

  def drop_unnecessary([], acc, _), do: Enum.reverse(acc)
  def drop_unnecessary([line | rest], acc, false) do
    if start?(line) do
      drop_unnecessary(rest, [line | acc], true)
    else
      drop_unnecessary(rest, acc, false)
    end
  end
  def drop_unnecessary([line | rest], acc, true), do: drop_unnecessary(rest, [line | acc], end?(line))

  # Minitest
  defp start?("Run options: " <> _), do: true
  # Rspec
  defp start?("Randomized with seed " <> _), do: true
  # Cucumber
  defp start?("Using the " <> _), do: true
  defp start?(_line), do: false

  # Rspec
  defp end?("Randomized with seed " <> _), do: false
  # Minitest
  defp end?("Finished in " <> rest), do: !(rest =~ ~r/assertions\/s\.$/)
  # Cucumber/else
  defp end?(line) do
    !(line =~ ~r/\d+ scenarios \(.*\)$/)
  end

  defp remove_colors(text), do: String.replace(text, ~r/\e\[.+?m/, "")
end
