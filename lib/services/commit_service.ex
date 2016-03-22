defmodule SlackCoder.Services.CommitService do
  alias SlackCoder.Repo

  def save(changeset) do
    response = Repo.save(changeset)
    SlackCoder.Models.notify_status(changeset)
    response
  end

end
