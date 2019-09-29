defmodule Bombadil.Search do
  @moduledoc false

  import Ecto.Query

  alias Bombadil.Ecto.Schema.SearchIndex

  # EXPLORE websearch
  # SELECT websearch_to_tsquery('english', '"supernovae stars" -crab');
  # TODO: Convert to opts the options ;)
  def search(search_query, opts \\ [operator: :or])

  def search(search_query, opts) when is_list(search_query) do
    operator = Keyword.get(opts, :operator, :or)
    search_query = to_tuple_list(search_query)
    construct_extact_match_query(search_query, operator)
  end

  def search(search_query, opts) when is_binary(search_query) do
    operator = Keyword.get(opts, :operator, :or)
    construct_extact_match_query(search_query, operator)
  end

  def fuzzy_search(schema, search_query, opts)
      when is_list(search_query) and is_atom(schema) and is_list(opts) do
    search_query = to_tuple_list(search_query)
    construct_fuzzy_query(schema, search_query, opts)
  end

  def fuzzy_search(schema, search_query, opts) when is_binary(search_query) do
    construct_fuzzy_query(schema, search_query, opts)
  end

  defp construct_extact_match_query(search_query, operator) do
    from(i in SearchIndex,
      where: ^Bombadil.Criteria.prepare(search_query, operator)
    )
  end

  defp construct_fuzzy_query(schema, search_query, opts) do
    context = Keyword.get(opts, :context, %{})

    from(i in schema,
      where: ^Bombadil.Criteria.prepare_fuzzy(search_query),
      where: ^Enum.into(context, [])
    )
  end

  defp to_tuple_list(search_query) do
    search_query
    |> Enum.map(fn element -> Enum.into(element, []) end)
    |> List.flatten()
  end
end
