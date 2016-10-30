defmodule SlackCoder.Github.Case do
  use ExUnit.CaseTemplate

  using do
    quote do
      use ExUnit.Case, async: true
      use Timex
      alias SlackCoder.Models.PR
      alias SlackCoder.Models.Comment
      alias SlackCoder.Models.User

      setup do
        Ecto.Adapters.SQL.Sandbox.checkout(SlackCoder.Repo)
      end
    end
  end
end
