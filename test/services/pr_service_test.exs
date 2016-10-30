defmodule SlackCoder.Models.PrServiceTest do
  use ExUnit.Case, async: true
  alias SlackCoder.Services.PRService

  describe "#next_backoff" do
    test "of start" do
      assert 4 == PRService.next_backoff(2, 2)
    end

    test "an hour past" do
      assert 4 == PRService.next_backoff(2, 3)
    end

    test "two hours past" do
      assert 8 == PRService.next_backoff(2, 4)
    end
  end
end
