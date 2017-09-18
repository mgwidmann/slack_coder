defmodule SlackCoder.BuildSystem.Semaphore do

  def build_info(_owner, _repo, _build_id) do
    []
  end

  def job_log(_build, _pr) do
    nil
  end
end
