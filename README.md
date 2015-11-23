SlackCoder
==========

## Slack Bot for watching your Github & (CI) builds

### Setup and deploy to Heroku

1. Fork and clone this repo
2. Checkout a deploy branch: `git checkout -b deploy`
3. Add `prod.secret.exs` file (See below for configuring)
4. Commit your `prod.secret.exs` **locally!!** `git commit -m 'Prod secret in local branch!'`
5. Deploy (See deploy instructions below)


### Configuring

You'll want to `config :slack_coder, ...` in your `prod.secret.exs` to give your bot the info it needs to know what to watch and who to report to. Heres an example of a configuration to watch a repo on github at `http://www.github.com/my_org/a_new_project`.

```elixir
config :slack_coder,
  slack_api_token: "Find your token here: https://api.slack.com/web",
  github: [
    pat: "Create your token here: https://github.com/settings/tokens",
    user: "the-github-user-name-that-goes-with-the-pat-token",
  ],
  # A list of all users the bot should talk to and their
  # github to slack username translation
  users: [
    mgwidmann: [slack: :matt]
  ],
  # The repositories to watch pull requests
  repos: [
    a_new_project: [
      owner: "my_org",
      users: [
        :mgwidmann
      ]
    ]},
    # Multiple repositories are configured as another item in the list
    old_project: [
      owner: "my_org",
      # Note that the users are repeated here. This is due to the fact that
      # the slack bot does not know which users work with which repositories
      users: [
        :mgwidmann
      ]
    ]
  ],
  # Finally where to report build notifications. All possible keys are channel
  # (string), group (string) and personal (boolean). The bot will only send the
  # notification to the first configured location it finds.
  group: "builds",
  # For stale PR notifications
  notifications: [
    # The minimum hour to send a notification (Just stale, passes/fails don't apply)
    min_hour: 8,
    # The maximum hour to send a notification (Just stale, passes/fails don't apply)
    max_hour: 17,
    # If you prefer to just always send notifications (don't bother with min/max then)
    always_allow: false,
    # The days on which to send stale PR notifications, 1 starts Monday
    # See Timex.Date.day_name/1 for more info
    days: [1,2,3,4,5]
  ],
  # If your timezone is different than the server timezone, enter string here
  timezone: "America/New_York",
  # Indicates the number of hours which to consider a PR stale at, must be a power of 2 (1,2,4,8,16,32,ect.)
  pr_backoff_start: 2
```

### Deploying

To deploy to Heroku, without publishing your `prod.secret.exs`, do the following git commands:

1. `git checkout deploy` (Your local only deploy branch)
2. `git merge master` (or whichever branch you want to deploy)
3. `git push heroku deploy:master`

Heroku will have a copy of your `prod.secret.exs`, but with this strategy it should stay out of Github and *somewhat* safer that way. You will have to either deploy from the same machine or push the code to safer git repository where you can safely commit your tokens, ect.
