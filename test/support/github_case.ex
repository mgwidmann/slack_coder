defmodule SlackCoder.Github.Case do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Pavlov.Case, async: true
      use Timex
      import Pavlov.Syntax.Expect
      alias SlackCoder.Models.PR
      alias SlackCoder.Models.Comment
      alias SlackCoder.Models.User

      before :each do
        Ecto.Adapters.SQL.Sandbox.checkout(SlackCoder.Repo)
      end
    end
  end
end
