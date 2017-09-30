defmodule SlackCoder.BuildSystem.LogParserTest do
  use ExUnit.Case
  alias SlackCoder.BuildSystem.{LogParser, File}

  describe "#parse" do
    test "finds the right seeds, files and type for each test" do
      assert [
        %File{
          seed: 21452,
          type: :rspec,
          file: {
                  "./spec/controllers/users/somethings_controller_spec.rb",
                  "375",
                  "User::SomethingsController PUT update with valid params redirect to homepage"
                }
        },
        %File{
          seed: nil,
          type: :cucumber,
          file: {
                  "features/something.feature",
                  "16",
                  "Scenario: Something"
                }
        }
      ] = Fixtures.Builds.failed_job() |> LogParser.parse()
    end

    test "handles rspecs weird line format" do
      assert [%File{
        file: {"./spec/some_spec.rb", "[1:2:3]", "The description[0m"}
      }] = LogParser.parse """
      Blah blah blah
      [31mrspec ./spec/some_spec.rb[1:2:3][0m [36m# The description[0m
      Blah blah blah
      """
    end

    test "handles numbers in the file name" do
      assert [%File{
        file: {"./spec/controllers/v1/some_spec.rb", "54", "The description[0m"}
      }] = LogParser.parse """
      Blah blah blah
      [31mrspec ./spec/controllers/v1/some_spec.rb:54[0m [36m# The description[0m
      Blah blah blah
      """
    end
  end
end
