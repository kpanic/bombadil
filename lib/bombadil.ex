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
  @spec fuzzy_search(String.t()) :: list()
  defdelegate fuzzy_search(query, opts \\ []), to: Bombadil.Search

  @doc """
  Index a document
  """
  @spec index(Keyword.t()) :: :ok | {:error, String.t()}
  defdelegate index(data, params \\ []), to: Bombadil.Index
end
