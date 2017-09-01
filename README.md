SlackCoder
==========

## Slack Bot for watching your Github & (CI) builds

### Nanobox deployment

You'll have to (install the nanobox CLI)[https://docs.nanobox.io/install/] tool first.

1. Fork and clone this repo
2. Run `nanobox dns add local slack-coder.dev` and follow instructions
3. Run `nanobox evar add local MIX_ENV=dev`
4. Run `nanobox run mix do ecto.create, ecto.migrate, run priv/repo/seeds.exs` to migrate your local database

To start it up, run `nanobox run iex -S mix phoenix.server`

### Configuring

You'll want to `config :slack_coder, ...` in your `prod.secret.exs` to give your bot the info it needs to know what to watch and who to report to. Heres an example of a configuration to watch a repo on github at `http://www.github.com/my_org/a_new_project`.

```elixir
config :slack_coder,
  slack_api_token: "Find your token here: https://api.slack.com/web",

config :slack_coder, :github,
  pat: "Create your token here: https://github.com/settings/tokens",
  user: "the-github-user-name-that-goes-with-the-pat-token",

config :slack_coder, :users,
  # A list of all users the bot should talk to and their
  # github to slack username translation
  mgwidmann: [slack: :matt]

config :slack_coder, :repos,
  # The repositories to watch pull requests
  [
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
  ]

config :slack_coder, :notifications,
  # Finally where to report build notifications. All possible keys are channel
  # (string), group (string) and personal (boolean). The bot will only send the
  # notification to the first configured location it finds (in the above order).
  channel: nil, # Won't post in any channel because of nil
  group: "builds", # Posts in a group
  # For stale PR notifications
  # The minimum hour to send a notification (Just stale, passes/fails don't apply)
  min_hour: 8,
  # The maximum hour to send a notification (Just stale, passes/fails don't apply)
  max_hour: 17,
  # If you prefer to just always send notifications (don't bother with min/max then)
  always_allow: false,
  # The days on which to send stale PR notifications, 1 starts Monday
  # See Timex.Date.day_name/1 for more info
  days: [1,2,3,4,5]
```

### Deploying

To deploy to Heroku, without publishing your `prod.secret.exs`, do the following git commands:

1. `git checkout deploy` (Your local only deploy branch)
2. `git merge master` (or whichever branch you want to deploy)
3. `git push heroku deploy:master`

Heroku will have a copy of your `prod.secret.exs`, but with this strategy it should stay out of Github and *somewhat* safer that way. You will have to either deploy from the same machine or push the code to safer git repository where you can safely commit your tokens, ect.
