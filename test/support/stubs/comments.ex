defmodule SlackCoder.Stubs.Comments do
  defmodule Issues do
    def list(_owner, _repo, "pr-opened", _client) do
      []
    end

    def list(_owner, _repo, _number, _client) do
      [
        %{"updated_at" => "2016-05-13T01:08:37.598Z", "html_url" => "http://github.com/old-issue-comment"},
        %{"updated_at" => "2016-05-17T01:08:37.598Z", "html_url" => "http://github.com/recent-issue-comment"}
      ]
    end
  end

  defmodule Pulls do
    def list(_owner, _repo, "pr-opened", _client) do
      []
    end
    def list(_owner, _repo, _number, _client) do
      [
        %{"updated_at" => "2016-05-12T01:08:37.598Z", "html_url" => "http://github.com/old-pr-comment"},
        %{"updated_at" => "2016-05-18T01:08:37.598Z", "html_url" => "http://github.com/recent-pr-comment"}
      ]
    end
  end
end
