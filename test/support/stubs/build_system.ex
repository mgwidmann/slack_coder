defmodule SlackCoder.Stubs.BuildSystem do
  defmodule Travis do
    alias SlackCoder.BuildSystem.{Build, File}

    def build_info(_owner, _repo, _build_id) do
      [
        %Build{id: 123, result: :failure}
      ]
    end
    def job_log(_build, pr) do
      [
        %File{
          id: 4,
          seed: 90872,
          type: :rspec,
          file: {"./spec/some/file.rb", "32", "The test name"},
        },
        %File{
          id: 4,
          seed: nil,
          type: :cucumber,
          file: {"features/some.feature", "14", "The cucumber test"}
        }
      ]
      |> SlackCoder.BuildSystem.record_failure_log("the really long failure log output...", pr)
    end
  end
  defmodule CircleCI do
    alias SlackCoder.BuildSystem.{Build, File}

    def build_info(_owner, _repo, _build_id) do
      [
        %Build{id: 123, result: :failure}
      ]
    end
    def job_log(_build, pr) do
      [
        %File{
          id: 4,
          seed: 90872,
          type: :rspec,
          file: {"./spec/some/file.rb", "32", "The test name"},
        },
        %File{
          id: 4,
          seed: nil,
          type: :cucumber,
          file: {"features/some.feature", "14", "The cucumber test"}
        }
      ]
      |> SlackCoder.BuildSystem.record_failure_log("the really long failure log output...", pr)
    end
  end
  defmodule Semaphore do
    alias SlackCoder.BuildSystem.{Build, File}

    def build_info(_owner, _repo, _build_id) do
      [
        %Build{id: 123, result: :failure}
      ]
    end
    def job_log(_build, pr) do
      [
        %File{
          id: 4,
          seed: 90872,
          type: :rspec,
          file: {"./spec/some/file.rb", "32", "The test name"},
        },
        %File{
          id: 4,
          seed: nil,
          type: :cucumber,
          file: {"features/some.feature", "14", "The cucumber test"}
        }
      ]
      |> SlackCoder.BuildSystem.record_failure_log("the really long failure log output...", pr)
    end
  end
end
