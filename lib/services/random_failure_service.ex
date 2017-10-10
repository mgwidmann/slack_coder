defmodule SlackCoder.Services.RandomFailureService do
  @moduledoc """
  """
  alias SlackCoder.Models.RandomFailure
  alias SlackCoder.BuildSystem.File
  alias SlackCoder.Repo
  alias SlackCoder.Models.PR
  require Logger

  def save(changeset) do
    changeset
    |> Repo.insert_or_update()
    |> case do
      {:ok, random_failure} ->
        if changeset.data.id && !changeset.data.resolved do
          {:ok, random_failure} # All is good
        else
          {:announce, changeset.data.resolved, random_failure}
        end
      errored_changeset ->
        Logger.error("Unable to save random failure\n\tchangeset: #{inspect changeset}\n\trandom failure: #{inspect changeset.data}")
        errored_changeset
    end
  end

  def save_random_failure(%PR{last_failed_jobs: []} = pr) do
    Logger.warn """
    Attempt to save random failed job but found no failure data.

    #{inspect pr, pretty: true}
    """
  end
  def save_random_failure(%PR{last_failed_jobs: [_ | _] = last_failed_jobs} = pr) do
    results = for %File{system: system, seed: seed, file: file, type: type, failure_log_id: failure_log_id} <- last_failed_jobs do
      find_or_create_and_update!(file, failure_log_id, system, type, seed, pr)
    end |> Enum.filter(&(match?({:announce, _, _}, &1)))
    previously_resolved = results |> Enum.map(&(elem(&1, 1))) |> Enum.any?
    if results != [], do: SlackCoder.Github.Notification.random_failure(pr, previously_resolved)
  end

  defp find_or_create_and_update!([], _id, _system, _type, _seed, _pr), do: nil
  defp find_or_create_and_update!({file, line, description}, failure_log_id, system, type, seed, pr) do
    RandomFailure.find_unique(pr.owner, pr.repo, file, line, description)
    |> Repo.one()
    |> case do
      %RandomFailure{count: count} = random_failure ->
        RandomFailure.changeset(random_failure, Map.merge(random_failure_updates(pr, file, line, description, seed, system, type), %{count: count + 1}))
      nil ->
        RandomFailure.changeset(%RandomFailure{}, random_failure_updates(pr, file, line, description, seed, system, type))
    end
    |> attach_log(failure_log_id)
    |> save()
  end

  defp random_failure_updates(pr, file, line, description, seed, system, type) do
    %{
      owner: pr.owner,
      repo: pr.repo,
      pr: pr.number,
      sha: pr.sha,
      file: file,
      line: to_string(line),
      description: description,
      seed: seed,
      count: 1,
      system: system,
      type: to_string(type),
      resolved: false
    }
  end

  def attach_log(%Ecto.Changeset{data: %RandomFailure{failure_log_id: nil}} = cs, failure_log_id) do
    Ecto.Changeset.put_change(cs, :failure_log_id, failure_log_id)
  end
  def attach_log(cs, _failure_log_id), do: cs
end
