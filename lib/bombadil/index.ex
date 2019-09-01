defmodule Bombadil.Index do
  alias Bombadil.Ecto.Schema.SearchIndex
  @spec index(Keyword.t() | Ecto.Changeset.t(), Keyword.t()) :: :ok | {:error, Ecto.Changeset.t()}
  def index(data, params) do
    changeset = prepare_changeset(data, params)

    with {:ok, _} = Bombadil.Repo.insert_or_update(changeset) do
      :ok
    end
  end

  defp prepare_changeset(data, params) when params == [] do
    Ecto.Changeset.change(struct(SearchIndex, data))
  end

  defp prepare_changeset(changeset, change_params) do
    change_params = Enum.into(change_params, %{})
    Ecto.Changeset.cast(changeset, change_params, Map.keys(change_params))
  end
end
