defmodule Bombadil.Index do
  @moduledoc false

  def index(schema, payload, params) do
    prepare_changeset(schema, payload, params)
  end

  defp prepare_changeset(schema, payload, params) when params == [] do
    Ecto.Changeset.change(struct(schema, payload))
  end

  defp prepare_changeset(_schema, changeset, change_params) do
    change_params = Enum.into(change_params, %{})
    Ecto.Changeset.cast(changeset, change_params, Map.keys(change_params))
  end
end
