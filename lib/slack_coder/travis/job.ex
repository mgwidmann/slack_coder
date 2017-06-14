defmodule SlackCoder.Travis.Job do
  use HTTPoison.Base
  defstruct [:seed, :rspec, :cucumber]

  def new(results) do
    %__MODULE__{
      seed: find_seed(results),
      rspec: find_rspec_failures(results),
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
    |> Enum.find(&match?("Randomized with seed" <> _, &1))
    |> case do
      s when is_binary(s) -> Regex.named_captures(@seed_regex, s)["seed"]
      _ -> nil
    end
  end

  defp find_rspec_failures(results) do
    results
    |> Stream.map(&Regex.named_captures(~r/rspec (?<file>.+)/, &1))
    |> Stream.filter(&(&1))
    |> Enum.map(&(Map.fetch!(&1, "file")))
  end

  defp find_cucumber_failures(results) do
    results
    |> Stream.map(&Regex.named_captures(~r/cucumber (?<file>.+)/, &1))
    |> Stream.filter(&(&1))
    |> Enum.map(&(Map.fetch!(&1, "file")))
  end

  def filter_log(body) do
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


  defimpl String.Chars do
    def to_string(%SlackCoder.Travis.Job{seed: seed, rspec: rspec, cucumber: cucumber}) do
      if rspec != [] do
        """
        bundle exec rspec #{Enum.join(rspec, " ")} --seed #{seed}
        """
      else
        ""
      end <> (if cucumber != [] do
        """
        bundle exec cucumber #{Enum.join(cucumber, " ")} --seed #{seed}
        """
      else
        ""
      end) |> String.trim_trailing()
    end
  end
end
