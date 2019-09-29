defmodule Bombadil do
  @moduledoc """
  Bombadil is a wrapper around some PostgreSQL search capabilities.

  It supports:
  * exact match through PostgreSQL tsvector(s)
  * fuzzy search inside jsonb field
  * indexing in the jsonb field
  """

  @doc """
  Search data with exact match of a string (or substring)

  Assuming that you have indexed `%{"book" => "Lord of the Rings}`

  ## Example:

      alias Bombadil.Ecto.Schema.SearchIndex

      iex> YourEctoRepo.all(Bombadil.search("Lord of the Rings"))
      [
        %Bombadil.Ecto.Schema.SearchIndex{
          __meta__: #Ecto.Schema.Metadata<:loaded, "search_index">,
          payload: %{"book" => "Lord of the Rings"},
          id: 1
        }
      ]
  """
  @spec search(String.t()) :: Ecto.Query.t()
  defdelegate search(query), to: Bombadil.Search

  @doc """
  Fuzzy search data of a string (or substring)

  Assuming that you have indexed `%{"book" => "Lord of the Rings}`

  ## Example:

      alias Bombadil.Ecto.Schema.SearchIndex

      iex> YourEctoRepo.all(Bombadil.fuzzy_search(SearchIndex, "lord of the ringz"))
      [
        %Bombadil.Ecto.Schema.SearchIndex{
          __meta__: #Ecto.Schema.Metadata<:loaded, "search_index">,
          payload: %{"book" => "Lord of the Rings"},
          id: 1
        }
      ]
  """
  @spec fuzzy_search(Ecto.Schema.t(), String.t() | list(), Keyword.t()) :: Ecto.Query.t()
  defdelegate fuzzy_search(schema, query, opts \\ []), to: Bombadil.Search

  @doc """
  Index a document payload as map

  ## Example:

      alias Bombadil.Ecto.Schema.SearchIndex

      YourEctoRepo.insert_or_update(Bombadil.index(SearchIndex, payload: %{"book" => "Lord of the Rings"}))
  """
  @spec index(Ecto.Schema.t(), Keyword.t() | Ecto.Changeset.t(), Keyword.t()) :: Ecto.Changeset.t()
  defdelegate index(schema, payload, params \\ []), to: Bombadil.Index
end
