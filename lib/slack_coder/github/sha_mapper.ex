defmodule SlackCoder.Github.ShaMapper do
  use GenServer
  @moduledoc """
  Github's webhook API delivers `push` and `status` events which has a lot of data about what just occurred except for
  the information of what PR it belongs to (which it may not).

  When a `push` event occurs, we will know that is the latest up to date commit SHA for a particular branch. At that time,
  a `status` event will follow it immediately.

  The purpose of this worker is to keep a mapping of commit SHA's to running pull requests and monitor their PIDs.
  """

  @doc """
  Starts a new ShaMapper. Don't call with any parameters to start up a singleton for the current node.
  """
  @registered_name __MODULE__
  def start_link(opts \\ [name: @registered_name]) do
    GenServer.start_link(__MODULE__, nil, opts)
  end

  def init(_) do
    {:ok, %{}}
  end

  def handle_info({:DOWN, _ref, :process, pid, :normal}, sha_to_pid) do
    {:noreply, cleanup(sha_to_pid, pid)}
  end
  # Ignore any other messages
  def handle_info(_, state), do: {:noreply, state}

  def handle_call({:register, sha}, {pid, _ref}, sha_to_pid) do
    handle_register(sha_to_pid, sha, pid)
  end

  def handle_call({:register, sha, pid}, _from, sha_to_pid) do
    handle_register(sha_to_pid, sha, pid)
  end

  def handle_call({:find, sha}, _from, sha_to_pid) do
    pid = Map.get(sha_to_pid, sha)
    pid = if pid && Process.alive?(pid) do
            pid
          else
            Task.start fn -> remove(sha) end
            nil
          end
    {:reply, pid, sha_to_pid}
  end

  def handle_call({:remove, sha}, _from, sha_to_pid) do
    {:reply, :ok, Map.drop(sha_to_pid, [sha])}
  end

  def handle_call(:list, _from, sha_to_pid) do
    {:reply, sha_to_pid, sha_to_pid}
  end

  def handle_cast({:update, old_sha, new_sha}, sha_to_pid) do
    pid = sha_to_pid |> Map.get(old_sha)
    {:noreply, if(pid, do: sha_to_pid |> Map.delete(old_sha) |> Map.put(new_sha, pid), else: sha_to_pid)}
  end

  def handle_register(sha_to_pid, sha, pid) do
    sha_to_pid = cleanup(sha_to_pid, pid)
    Process.monitor(pid) # Watch what happens with this PID and be notified when it exits
    {:reply, :ok, Map.put(sha_to_pid, sha, pid)}
  end

  def cleanup(sha_to_pid, pid) when is_pid(pid) do
    sha_to_pid
    |> Enum.reject(&match?({_sha, ^pid}, &1))
    |> Enum.into(%{})
  end

  @doc """
  Registers a PR against a starting commit SHA
  """
  def register(sha_mapper \\ @registered_name, sha) do
    GenServer.call(sha_mapper, {:register, sha})
  end

  def register_pid(sha_mapper \\ @registered_name, sha, pid)
  def register_pid(sha_mapper, sha, pid) when is_pid(pid) do
    GenServer.call(sha_mapper, {:register, sha, pid})
  end
  def register_pid(_sha_mapper, _sha, nil), do: nil

  @doc """
  Updates the mapping of the old PR to its latest SHA
  """
  def update(sha_mapper \\ @registered_name, old_sha, new_sha) do
    GenServer.cast(sha_mapper, {:update, old_sha, new_sha})
  end

  def remove(sha_mapper \\ @registered_name, sha) do
    GenServer.call(sha_mapper, {:remove, sha})
  end

  @doc """
  Finds the PR pid based on the current SHA
  """
  def find(sha_mapper \\ @registered_name, sha) do
    GenServer.call(sha_mapper, {:find, sha})
  end

  def list(sha_mapper \\ @registered_name) do
    GenServer.call(sha_mapper, :list)
  end
end
