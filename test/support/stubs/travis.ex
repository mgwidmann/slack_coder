defmodule SlackCoder.Stubs.Travis do
  alias SlackCoder.Travis.Job
  alias SlackCoder.Travis.Build

  def build_info(_owner, _repo, _build_id) do
    [
      %Build{result: :failure}
    ]
  end
  def job_log(_build) do
    %Job{rspec_seed: "90872", rspec: [{"./spec/some/file.rb", 32}], cucumber_seed: "27832", cucumber: [{"features/some.feature", 14}]}
  end

end
