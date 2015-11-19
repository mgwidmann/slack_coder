defmodule SlackCoder.Repo do
  use Ecto.Repo, otp_app: :slack_coder

  def save(%Ecto.Changeset{model: %{id: nil}} = changeset) do
    insert(changeset)
  end

  def save(%Ecto.Changeset{model: %{id: _id}} = changeset) do
    update(changeset)
  end
end
