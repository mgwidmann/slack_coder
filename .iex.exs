alias SlackCoder.Repo
import_if_available Ecto.Query
alias SlackCoder.Models.PR
alias SlackCoder.Github.Watchers.Supervisor, as: GithubSupervisor
alias SlackCoder.Github
alias SlackCoder.Models.User
alias SlackCoder.Models.Config
alias SlackCoder.Models.Message
alias SlackCoder.Models.RandomFailure
alias SlackCoder.Models.RandomFailure.FailureLog
