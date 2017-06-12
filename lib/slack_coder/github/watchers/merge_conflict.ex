defmodule SlackCoder.Github.Watchers.MergeConflict do
  use GenServer
  alias SlackCoder.Github.Watchers.PullRequest, as: PullRequest
  alias SlackCoder.Github.Watchers.Supervisor, as: Github

  @moduledoc """
  Github's webhook API delivers a `mergeable_state` as "unknown" since no one has inquired about
  the status of the PR (by visiting the webpage or hitting the API). This worker is responsible for
  keeping track of PRs that need to have their mergeable state checked and querying the Github API
  directly. Once a result besides "unknown" is obtained, the PR is updated with the new mergeable state.
  """

  def start_link() do
    GenServer.start_link(__MODULE__, %{prs: []}, name: __MODULE__)
  end

  @one_minute 60 * 1_000
  def init(state) do
    Process.send_after(self(), :check_conflicts, @one_minute)
    {:ok, state}
  end

  @mergeable_query """
  query ($owner: String!, $name: String!, $number: Int!, $owner2: String!, $name2: String!, $number2: Int!, $owner3: String!, $name3: String!, $number3: Int!, $owner4: String!, $name4: String!, $number4: Int!, $owner5: String!, $name5: String!, $number5: Int!) {
    one: repository(owner: $owner, name: $name) {
      pullRequest(number: $number) {
        number
      	mergeable
        repository {
          name
          owner {
            login
          }
        }
      }
    }
    two: repository(owner: $owner2, name: $name2) {
      pullRequest(number: $number2) {
        number
      	mergeable
        repository {
          name
          owner {
            login
          }
        }
      }
    }
    three: repository(owner: $owner3, name: $name3) {
      pullRequest(number: $number3) {
        number
      	mergeable
        repository {
          name
          owner {
            login
          }
        }
      }
    }
    four: repository(owner: $owner4, name: $name4) {
      pullRequest(number: $number4) {
        number
      	mergeable
        repository {
          name
          owner {
            login
          }
        }
      }
    }
    five: repository(owner: $owner5, name: $name5) {
      pullRequest(number: $number5) {
        number
      	mergeable
        repository {
          name
          owner {
            login
          }
        }
      }
    }
  }
  """
  @unknown "UNKNOWN"

  def handle_info(:check_conflicts, %{prs: []} = state) do
    Process.send_after(self(), :check_conflicts, @one_minute)
    {:noreply, state}
  end
  def handle_info(:check_conflicts, %{prs: prs} = state) do
    prs = case SlackCoder.Github.query(@mergeable_query, variable_params(prs)) do
            {:ok, response} ->
              response_prs = Map.values(response["data"]) |> Enum.map(&(&1["pullRequest"])) |> Enum.filter(&(&1))

              Enum.reject(prs, fn(pr) ->
                response = Enum.find(response_prs, &(&1["number"] == pr.number && &1["repository"]["name"] == pr.repo && &1["repository"]["owner"]["login"] == pr.owner))
                if response && response["mergeable"] != @unknown do
                  pr
                  |> Github.find_watcher()
                  |> PullRequest.update_sync(%{"mergeable_state" => String.downcase(response["mergeable"])})
                end
              end)
            error ->
              Logger.error "Received unexpected response from Github: #{inspect error}"
              prs
          end

    Process.send_after(self(), :check_conflicts, @one_minute)
    {:noreply, Map.put(state, :prs, prs)}
  end

  defp variable_params(prs) do
    %{
      owner: Map.get(Enum.at(prs, 0) || %{}, :owner) || "",
      name: Map.get(Enum.at(prs, 0) || %{}, :repo) || "",
      number: Map.get(Enum.at(prs, 0) || %{}, :number) || 0,
      owner2: Map.get(Enum.at(prs, 1) || %{}, :owner) || "",
      name2: Map.get(Enum.at(prs, 1) || %{}, :repo) || "",
      number2: Map.get(Enum.at(prs, 1) || %{}, :number) || 0,
      owner3: Map.get(Enum.at(prs, 2) || %{}, :owner) || "",
      name3: Map.get(Enum.at(prs, 2) || %{}, :repo) || "",
      number3: Map.get(Enum.at(prs, 2) || %{}, :number) || 0,
      owner4: Map.get(Enum.at(prs, 3) || %{}, :owner) || "",
      name4: Map.get(Enum.at(prs, 3) || %{}, :repo) || "",
      number4: Map.get(Enum.at(prs, 3) || %{}, :number) || 0,
      owner5: Map.get(Enum.at(prs, 4) || %{}, :owner) || "",
      name5: Map.get(Enum.at(prs, 4) || %{}, :repo) || "",
      number5: Map.get(Enum.at(prs, 4) || %{}, :number) || 0,
    }
  end

  def handle_call({:add, pr}, _, %{prs: prs} = state) do
    {:reply, :ok, Map.put(state, :prs, Enum.uniq_by([pr | prs], &(&1.id)))}
  end

  def queue(pr) do
    GenServer.call(__MODULE__, {:add, pr})
  end
end
