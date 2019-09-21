defmodule Bombadil.Index do
  @moduledoc false

  alias Ecto.Schema

  @spec index(Schema.t(), Keyword.t()) :: :ok | {:error, Ecto.Changeset.t()}
  def index(schema, payload) do
    changeset = prepare_changeset(schema, payload)

    with {:ok, _} = Bombadil.Repo.insert_or_update(changeset) do
      :ok
    end
  end

  defp prepare_changeset(schema, payload) do
    Ecto.Changeset.change(struct(schema, payload))
  end
end
