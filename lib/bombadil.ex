defmodule Bombadil do
  @moduledoc """
  Bombadil, indexes and searches your data
  """

  @doc """
  Search data
  """
  @spec search(String.t() | list()) :: list()
  defdelegate search(query), to: Bombadil.Search

  @doc """
  Fuzzy search data
  """
  @spec fuzzy_search(Ecto.Schema.t(), String.t() | list(), Keyword.t()) :: list()
  defdelegate fuzzy_search(schema, query, opts \\ []), to: Bombadil.Search

  @doc """
  Index a document
  """
  @spec index(Ecto.Schema.t(), map(), list()) :: :ok | {:error, String.t()}
  defdelegate index(schema, payload, params \\ []), to: Bombadil.Index
end
