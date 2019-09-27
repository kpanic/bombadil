defmodule Bombadil.Index do
  @moduledoc false

  alias Ecto.Schema

  @spec index(Schema.t(), Keyword.t() | Ecto.Changeset.t(), Keyword.t()) ::
          :ok | {:error, Ecto.Changeset.t()}
  def index(schema, payload, params) do
    changeset = prepare_changeset(schema, payload, params)

    with {:ok, _} = Bombadil.Repo.insert_or_update(changeset) do
      :ok
    end
  end

  defp prepare_changeset(schema, payload, params) when params == [] do
    Ecto.Changeset.change(struct(schema, payload))
  end

  defp prepare_changeset(_schema, changeset, change_params) do
    change_params = Enum.into(change_params, %{})
    Ecto.Changeset.cast(changeset, change_params, Map.keys(change_params))
  end
end
