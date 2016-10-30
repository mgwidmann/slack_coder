if function_exported?(SlackCoder, :start_link, 2) do
  quote do
    alias SlackCoder.Repo
    import Ecto.Query
    alias SlackCoder.Models.PR
    alias SlackCoder.Models.Commit
    alias SlackCoder.Github.Supervisor, as: Github
    alias SlackCoder.Models.User
    alias SlackCoder.Models.Config
  end |> Code.eval_quoted
end
