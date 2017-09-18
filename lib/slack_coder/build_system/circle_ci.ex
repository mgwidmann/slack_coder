defmodule SlackCoder.BuildSystem.CircleCI do

  def build_info(_owner, _repo, _build_id) do
    [] # Not yet implemented
  end

  def job_log(_build, _pr) do
    nil
  end
end
