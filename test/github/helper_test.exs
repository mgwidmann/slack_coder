defmodule SlackCoder.Github.HelperTest do
  use Pavlov.Case, async: true
  import Pavlov.Syntax.Expect
  alias SlackCoder.Github.Helper
  alias SlackCoder.Github.PullRequest.PR

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

        it "uses the default" do
          expect Helper.get("non/200/success") |> to_eq []
        end

        it "uses the default" do
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
    before :each do
      allow(HTTPoison) |> to_receive(get: fn(_url, _headers)-> {:ok, %HTTPoison.Response{status_code: 200, body: JSX.encode!(response)}} end)
      :ok
    end
    let :response do
      [%{
        "user" => %{"login" => "slack_coder"},
        "base" => %{"repo" => %{"name" => "cool_project", "owner" => %{"login" => "slack_coder"}}},
        "_links" => %{"commits" => %{"href" => "github.com/commits"}},
        "title" => "A new idea"
      }]
    end

    it "returns pull request structs" do
      Helper.pulls(:cool_project)
      assert_receive {:pr_response, [
        %PR{
          commits_url: "commits",
          slack_user: :slack_coder,
          statuses_url: "repos/slack_coder/cool_project/statuses/",
          title: "A new idea"
        }
        ]}
    end
  end

end
