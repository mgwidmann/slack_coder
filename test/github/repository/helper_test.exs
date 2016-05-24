defmodule SlackCoder.Github.Repository.HelperTest do
  use SlackCoder.Github.Case, async: true
  alias SlackCoder.Github.Watchers.Repository.Helper

  describe "pulls" do
    describe "#find_latest_comment_date" do
      it "returns the latest comment date and its url" do
        assert %{latest_comment: _date, latest_comment_url: _url} = Helper.find_latest_comment_date(%PR{})
      end

      it "returns the correct comment date" do
        assert %{latest_comment: date} = Helper.find_latest_comment_date(%PR{})
        assert Timex.format!(date, "{ISOz}") == "2016-05-18T01:08:37.598Z"
      end

      it "returns the correct comment url" do
        assert %{latest_comment_url: url} = Helper.find_latest_comment_date(%PR{})
        assert url == "http://github.com/recent-pr-comment"
      end

      it "otherwise returns the pr opened at" do
        now = Timex.DateTime.now
        assert %{latest_comment: date} = Helper.find_latest_comment_date(%PR{number: "pr-opened", opened_at: now})
        assert Timex.DateTime.compare(now, date)
      end
    end

    describe "#handle_closed_pr" do
      it "returns changeset when there are no old prs" do
        assert %Ecto.Changeset{} == Helper.handle_closed_pr(%Ecto.Changeset{}, [])
      end

      describe "for a list of old prs" do
        let(:valid_pr, do: %SlackCoder.Models.PR{number: 1, owner: "o", repo: "r", branch: "b", github_user: "g", title: "t", html_url: "h", opened_at: Timex.DateTime.now})
        let(:old_prs, do: [valid_pr])
        let(:changeset, do: SlackCoder.Models.PR.reg_changeset(%SlackCoder.Models.PR{}))

        it "returns changeset if cannot be found" do
          assert changeset == Helper.handle_closed_pr(changeset, old_prs)
        end

        let(:merged_changeset, do: SlackCoder.Models.PR.reg_changeset(valid_pr, %{merged_at: Timex.DateTime.now}))
        it "sets a merged notification" do
          assert merged_changeset
            |> Helper.handle_closed_pr(old_prs)
            |> Ecto.Changeset.get_change(:notifications) == [:merged]
        end

        let(:closed_changeset, do: SlackCoder.Models.PR.reg_changeset(valid_pr, %{closed_at: Timex.DateTime.now}))
        it "sets a closed notification" do
          assert closed_changeset
            |> Helper.handle_closed_pr(old_prs)
            |> Ecto.Changeset.get_change(:notifications) == [:closed]
        end
      end
    end

    describe "#stale_notification" do
      let(:valid_pr, do: %SlackCoder.Models.PR{number: 1, backoff: 2, owner: "o", repo: "r", branch: "b", github_user: "g", title: "t", html_url: "h", opened_at: Timex.DateTime.now})
      let(:one_hour_ago, do: Timex.DateTime.now |> Timex.shift(hours: 1))
      let(:two_hours_ago, do: Timex.DateTime.now |> Timex.shift(hours: 2))

      let(:changeset, do: SlackCoder.Models.PR.reg_changeset(valid_pr))
      it "returns the changeset unchanged" do
        assert %Ecto.Changeset{changes: %{}} = Helper.stale_notification(changeset)
      end

      let(:stale_changeset, do: SlackCoder.Models.PR.reg_changeset(valid_pr, %{latest_comment: two_hours_ago}))
      it "ups backoff and puts stale notification" do
        assert %Ecto.Changeset{changes: %{backoff: 4, notifications: [:stale]}} = Helper.stale_notification(stale_changeset)
      end

      let(:not_stale_changeset, do: SlackCoder.Models.PR.reg_changeset(valid_pr, %{latest_comment: one_hour_ago}))
      it "doesnt change anything" do
        assert %{latest_comment: one_hour_ago} == Helper.stale_notification(not_stale_changeset).changes
      end
    end

    describe "#unstale_notification" do
      let(:valid_pr, do: %SlackCoder.Models.PR{number: 1, backoff: 2, owner: "o", repo: "r", branch: "b", github_user: "g", title: "t", html_url: "h", opened_at: Timex.DateTime.now, latest_comment: four_hours_ago})
      let(:one_hour_ago, do: Timex.DateTime.now |> Timex.shift(hours: 1))
      let(:four_hours_ago, do: Timex.DateTime.now |> Timex.shift(hours: 4))

      let(:changeset, do: SlackCoder.Models.PR.reg_changeset(valid_pr))
      it "returns the changeset unchanged" do
        assert %Ecto.Changeset{changes: %{}} = Helper.unstale_notification(changeset)
      end

      let(:unstale_changeset, do: SlackCoder.Models.PR.reg_changeset(%SlackCoder.Models.PR{ valid_pr | backoff: 4}, %{latest_comment: Timex.DateTime.now}))
      it "resets backoff and puts unstale notification" do
        assert %Ecto.Changeset{changes: %{backoff: 2, notifications: [:unstale]}} = Helper.unstale_notification(unstale_changeset)
      end

      let(:not_unstale_changeset, do: SlackCoder.Models.PR.reg_changeset(valid_pr, %{latest_comment: one_hour_ago}))
      it "doesnt change anything" do
        assert %{latest_comment: one_hour_ago} == Helper.stale_notification(not_unstale_changeset).changes
      end
    end

    describe "#next_backoff" do
      it "of start" do
        assert 4 == Helper.next_backoff(2, 2)
      end

      it "an hour past" do
        assert 4 == Helper.next_backoff(2, 3)
      end

      it "two hours past" do
        assert 8 == Helper.next_backoff(2, 4)
      end
    end
  end
end
