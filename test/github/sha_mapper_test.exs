defmodule SlackCoder.Github.ShaMapperTest do
  use ExUnit.Case
  alias SlackCoder.Github.ShaMapper

  @sha "thesha"

  describe "registration" do
    test "receives registration requests" do
      spawn(ShaMapper, :register, [self, @sha])
      assert_receive {:"$gen_call", _from, {:register, @sha}}
    end

    test "monitors pids that register" do
      pid = spawn fn -> receive do _ -> nil end end # Wait until getting a message
      ShaMapper.handle_call({:register, @sha}, {pid, make_ref}, %{})
      send(pid, :bye) && Process.sleep(100)
      refute Process.alive?(pid)
      assert_receive {:DOWN, _, :process, _pid, :normal}
    end

    test "updates the state with the new SHA and PID" do
      s = self()
      assert {:reply, :ok, %{@sha => ^s}} = ShaMapper.handle_call({:register, @sha}, {s, make_ref}, %{})
    end
  end

  describe "finding" do
    setup do
      {:ok, pid} = ShaMapper.start_link([]) # Don't register name
      ShaMapper.register(pid, @sha)
      {:ok, %{pid: pid}}
    end

    test "can find the pid by the registered name", %{pid: pid} do
      s = self()
      assert ^s = ShaMapper.find(pid, @sha)
    end

    test "returns nil when none is found", %{pid: pid} do
      refute ShaMapper.find(pid, "doesnotexist")
    end
  end

  describe "updating" do
    setup do
      {:ok, pid} = ShaMapper.start_link([]) # Don't register name
      ShaMapper.register(pid, @sha)
      {:ok, %{pid: pid}}
    end

    test "updates the map", %{pid: pid} do
      ShaMapper.update(pid, @sha, "newsha")
      assert ShaMapper.find(pid, "newsha")
    end

    test "doesn't corrupt when a SHA does not exist", %{pid: pid} do
      ShaMapper.update(pid, "nonexistentsha", "newsha")
      refute ShaMapper.find(pid, "nonexistentsha")
      refute ShaMapper.find(pid, "newsha")
    end
  end
end
