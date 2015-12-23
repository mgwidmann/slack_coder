defmodule SlackCoder.Repo do
  use Ecto.Repo, otp_app: :slack_coder

  # Unsure if this is what Jose intended when he removed callbacks :/
  def save(%Ecto.Changeset{model: %{id: nil}} = changeset) do
    case insert(changeset) do
      {:ok, model} ->
        if function_exported? model.__struct__, :after_save, 1 do
          cs = %Ecto.Changeset{changeset | model: model}
          apply model.__struct__, :after_save, [cs]
        end
        {:ok, model}
      {:error, cs} -> {:error, cs}
    end
  end

  def save(%Ecto.Changeset{model: %{id: _id}} = changeset) do
    case update(changeset) do
      {:ok, model} ->
        if function_exported? model.__struct__, :after_save, 1 do
          cs = %Ecto.Changeset{changeset | model: model}
          apply model.__struct__, :after_save, [cs]
        end
        {:ok, model}
      {:error, cs} -> {:error, cs}
    end
  end

  # Fun addition
  def count(queryable) do
    import Ecto.Query
    one(from q in queryable, select: count(q.id))
  end
end
