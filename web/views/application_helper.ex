defmodule SlackCoder.ApplicationHelper do
  use Phoenix.HTML

  def link_if(condition, opts, [do: block]) do
    if condition && opts[:to] do
      link(opts, [do: block])
    else
      content_tag :span, opts, do: block
    end
  end

  def users_list(except \\ nil) do
    SlackCoder.Users.Supervisor.users
    |> Enum.reject(fn(user)->
        user.github == except
    end)
    |> Enum.map(fn(user)->
      {"#{user.name} (#{user.github})", String.downcase(user.github)}
    end)
  end

  @git_commit System.cmd("git", ["rev-parse", "HEAD"]) |> elem(0)
  def git_commit(), do: @git_commit

  def ueberauth_strategy do
    [{provider, _}] = Application.get_env(:ueberauth, Ueberauth)[:providers]
    provider
  end
end
