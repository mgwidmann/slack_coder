defmodule SlackCoder.Services.RandomFailureService do
  @moduledoc """
  """
  alias SlackCoder.Models.RandomFailure
  alias SlackCoder.BuildSystem.Job
  alias SlackCoder.Repo
  require Logger

  def save(changeset) do
    changeset
    |> Repo.insert_or_update()
    |> case do
      {:ok, random_failure} ->
        {:ok, random_failure} # All is good
      errored_changeset ->
        Logger.error("Unable to save random failure\n\tchangeset: #{inspect changeset}\n\trandom failure: #{inspect changeset.data}")
        errored_changeset
    end
  end

  def save_random_failure(pr) do
    for %Job{rspec: rspec, rspec_seed: rspec_seed, cucumber: cucumber, cucumber_seed: cucumber_seed} <- pr.last_failed_jobs do
      find_or_create_and_update!(rspec, rspec_seed, pr)
      find_or_create_and_update!(cucumber, cucumber_seed, pr)
    end
  end

  defp find_or_create_and_update!([], _seed, _pr), do: nil
  defp find_or_create_and_update!([{file, line} | failures], seed, pr) do
    RandomFailure.find_unique(pr.owner, pr.repo, file, line)
    |> Repo.one()
    |> case do
      %RandomFailure{count: count} = random_failure ->
        RandomFailure.changeset(random_failure, %{count: count + 1})
      nil ->
        RandomFailure.changeset(%RandomFailure{}, %{
          owner: pr.owner,
          repo: pr.repo,
          pr: pr.number,
          sha: pr.sha,
          file: file,
          line: line,
          seed: seed,
          count: 1,
          log_url: pr.build_url
        })
    end
    |> save()

    find_or_create_and_update!(failures, seed, pr)
  end
end
