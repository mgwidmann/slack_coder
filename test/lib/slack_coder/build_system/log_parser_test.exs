defmodule SlackCoder.BuildSystem.LogParserTest do
  use ExUnit.Case
  alias SlackCoder.BuildSystem.{LogParser, Job, Job.Test}

  describe "#parse" do
    test "finds the right seeds, files and type for each test" do
      assert %Job{
        tests: [
          %Test{
            seed: 21452,
            type: :rspec,
            files: [
              {
                "./spec/controllers/users/somethings_controller_spec.rb",
                "375",
                "User::SomethingsController PUT update with valid params redirect to homepage"
              }
            ]
          },
          %Test{
            seed: nil,
            type: :cucumber,
            files: [
              {
                "features/something.feature",
                "16",
                "Scenario: Something"
              }
            ]
          }
        ]
      } = Fixtures.Builds.failed_job() |> LogParser.parse()
    end

    test "handles rspecs weird line format" do
      assert %Job{tests: [%Test{
        files: [{"./spec/some_spec.rb", "[1:2:3]", "The description[0m"}]
      }]} = LogParser.parse """
      Blah blah blah
      [31mrspec ./spec/some_spec.rb[1:2:3][0m [36m# The description[0m
      Blah blah blah
      """
    end
  end

end
