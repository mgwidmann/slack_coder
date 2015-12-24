defmodule SlackCoder.Github.HelperTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect
  alias SlackCoder.Github.Helper
  alias SlackCoder.Models.PR
  alias SlackCoder.Models.User
  alias SlackCoder.Repo

  describe "get" do
    before :each do
      allow(HTTPoison) |> to_receive(get: fn(_url, _headers)-> response end)
      :ok
    end

    let :response do
      {:ok, %HTTPoison.Response{status_code: 200, body: "{}"}}
    end

    context "successful" do
      it "handles successful responses" do
        expect Helper.get("successful/return/map") |> to_eq %{}
      end
      it "ignores default" do
        expect Helper.get("with/default/ignore", [default: :data]) |> to_eq %{}
      end

      context "non-200 status" do
        let :response do
          {:ok, %HTTPoison.Response{status_code: 123, body: ~S({"message": "Error"}) }}
        end

        it "returns empty list without default" do
          expect Helper.get("non/200/success") |> to_eq []
        end

        it "returns default when supplied" do
          expect Helper.get("non/200/success", [default: :data]) |> to_eq [default: :data]
        end
      end
    end

    context "error" do
      let :response do
        {:error, %HTTPoison.Error{reason: "Just cause"}}
      end

      it "handles error responses, returning default" do
        expect Helper.get("error/without/default") |> to_eq []
      end

      it "handles error responses with optinal default" do
        expect Helper.get("error/with/default", [default: :data]) |> to_eq [default: :data]
      end
    end

  end

  describe "pulls" do
    let :user do
      :random.seed :erlang.phash2([node]), :erlang.monotonic_time, :erlang.unique_integer
      # "user-#{:random.uniform(1_000)}"
      "slack-user"
    end
    before :each do
      unless SlackCoder.Repo.get_by(SlackCoder.Models.User, slack: user) do
        %SlackCoder.Models.User{github: user, slack: user} |> SlackCoder.Repo.insert
      end
      response # Create response here so it matches user
      allow(HTTPoison) |> to_receive(get: fn(_url, _headers)-> {:ok, %HTTPoison.Response{status_code: 200, body: JSX.encode!(response)}} end)
      :ok
    end
    let :number, do: 0
    let :response do
      [%{
        "user" => %{"login" => user},
        "base" => %{"repo" => %{"name" => "cool_project", "owner" => %{"login" => "slack_coder"}}},
        "_links" => %{"commits" => %{"href" => "github.com/commits"}, "html" => %{"href" => "github.com/pulls"}},
        "title" => "A new idea",
        "number" => number,
        "head" => %{"ref" => "branch"},
        "created_at" => "2015-11-19T22:18:37Z"
      }]
    end

    context "when PR is opened" do
      let :number, do: 123
      it "returns a new pull request" do
        Helper.pulls(:cool_project)
        assert_receive {:pr_response, [
          %PR{
            statuses_url: "repos/slack_coder/cool_project/statuses/",
            title: "A new idea",
            number: 123,
            branch: "branch",
            html_url: "github.com/pulls"
          }
        ]}
      end
    end

    context "when the PR exists" do
      let :number, do: 456
      let :existing_pr, do: %SlackCoder.Models.PR{number: number, owner: "foo", branch: "branch", title: "old title", repo: "repo", github_user: "user", html_url: "url", opened_at: Timex.Date.now}
      it "returns an updated pull request" do
        {:ok, pr} = Repo.insert(existing_pr)
        id = pr.id
        number = pr.number
        Helper.pulls(:cool_project)
        assert_receive {:pr_response, [
          %PR{
            id: ^id,
            title: "A new idea",
            number: ^number
          }
        ]}
      end
    end
  end

  describe "find_latest_comment" do
    before :each do
      allow(HTTPoison) |> to_receive(get: fn
        "https://slack_coder:pat-123@api.github.com/repos/o/r/issues/1/comments", _headers -> issue_response
        "https://slack_coder:pat-123@api.github.com/repos/o/r/pulls/1/comments", _headers -> pull_response
      end)
      :ok
    end
    let :pr, do: %SlackCoder.Models.PR{owner: "o", repo: "r", number: 1}
    let :issue_response do
      {:ok, %HTTPoison.Response{status_code: 200, body: JSX.encode!(issue_body)}}
    end
    let :issue_body, do: [%{updated_at: "2015-11-20T10:01:23Z"}]
    let :pull_response do
      {:ok, %HTTPoison.Response{status_code: 200, body: JSX.encode!(pull_body)}}
    end
    let :pull_body, do: [%{updated_at: "2015-11-21T10:00:49Z"}]

    it "returns the greater date" do
      cs = Helper.find_latest_comment(pr)
      expect cs.changes[:latest_comment] |> to_eq(%Timex.DateTime{calendar: :gregorian, day: 21, hour: 10, minute: 0,
        month: 11, ms: 0, second: 49, timezone: %Timex.TimezoneInfo{abbreviation: "UTC", from: :min, full_name: "UTC",
        offset_std: 0, offset_utc: 0, until: :max}, year: 2015})
    end

    context "when one is nil" do
      let :pull_body, do: []
      it "returns the other" do
        cs = Helper.find_latest_comment(pr)
        expect cs.changes[:latest_comment] |> to_eq(%Timex.DateTime{calendar: :gregorian, day: 20, hour: 10, minute: 1,
          month: 11, ms: 0, second: 23, timezone: %Timex.TimezoneInfo{abbreviation: "UTC", from: :min, full_name: "UTC",
          offset_std: 0, offset_utc: 0, until: :max}, year: 2015})
      end
    end
  end

end
