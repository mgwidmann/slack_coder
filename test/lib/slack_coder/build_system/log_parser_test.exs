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
      ] = Fixtures.Builds.failed_rspec_and_cucumber() |> LogParser.parse()
    end

    test "handles rspecs weird line format" do
      assert [%File{
        file: {"./spec/some_spec.rb", "[1:2:3]", "The description[0m"}
      }] = LogParser.parse """
      Randomized with seed 1234
      Blah blah blah
      [31mrspec ./spec/some_spec.rb[1:2:3][0m [36m# The description[0m
      Blah blah blah
      Randomized with seed 1234
      """
    end

    test "handles numbers in the file name" do
      assert [%File{
        file: {"./spec/controllers/v1/some_spec.rb", "54", "The description[0m"}
      }] = LogParser.parse """
      Randomized with seed 1234
      Blah blah blah
      [31mrspec ./spec/controllers/v1/some_spec.rb:54[0m [36m# The description[0m
      Blah blah blah
      Randomized with seed 1234
      """
    end

    test "minitest failures" do
      [
        %File{
          type: :minitest,
          seed: 26781,
          file: {"test/user/profile/edit_test.rb", "33", "UserTest::ProfileEditing#test_admin_can_edit"}
        },
        %File{
          type: :minitest,
          seed: 26781,
          file: {"test/user/profile/edit_test.rb", "43", "UserTest::ProfileEditing#test_user_can_edit"}
        }
      ] = Fixtures.Builds.failed_minitest() |> LogParser.parse()
    end
  end
end
