defmodule SlackCoder.Stubs.Github do
  def blame(_owner, _repo, _sha, _file, _line) do
    %{
      "user" => %{
        "name" => "User 1",
        "login" => "user1"
      },
      "avatarUrl" => "http://github.com/some/avatar.png",
      "email" => "user1@example.com"
    }
  end
end
