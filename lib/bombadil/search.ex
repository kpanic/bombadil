defmodule Bombadil.Search do
  @moduledoc false

  import Ecto.Query

  # EXPLORE websearch
  # SELECT websearch_to_tsquery('english', '"supernovae stars" -crab');
  # TODO: Convert to opts the options ;)
  def search(schema, search_query, opts \\ [])

  def search(schema, search_query, opts) when is_list(search_query) do
    search_query = to_tuple_list(search_query)
    construct_exact_match_query(schema, search_query, opts)
  end

  def search(schema, search_query, opts) when is_binary(search_query) do
    construct_exact_match_query(schema, search_query, opts)
  end

  def fuzzy_search(schema, search_query, opts)
      when is_list(search_query) and is_atom(schema) and is_list(opts) do
    search_query = to_tuple_list(search_query)
    construct_fuzzy_query(schema, search_query, opts)
  end

  def fuzzy_search(schema, search_query, opts) when is_binary(search_query) do
    construct_fuzzy_query(schema, search_query, opts)
  end

  defp construct_exact_match_query(schema, search_query, opts) do
    context = Keyword.get(opts, :context, %{})

    order_by = Bombadil.Criteria.order_by(search_query)

    from(i in schema,
      where: ^Enum.into(context, []),
      where: ^Bombadil.Criteria.prepare(search_query),
      order_by: ^order_by
    )
  end

  defp construct_fuzzy_query(schema, search_query, opts) when is_binary(search_query) do
    context = Keyword.get(opts, :context, %{})

    from(i in schema,
      where: ^Enum.into(context, []),
      where: ^Bombadil.Criteria.prepare_fuzzy(search_query),
      order_by: [asc: i.payload]
    )
  end

  defp construct_fuzzy_query(schema, search_query, opts) do
    context = Keyword.get(opts, :context, %{})

    order_by = Bombadil.Criteria.order_by(search_query)

    from(i in schema,
      where: ^Enum.into(context, []),
      where: ^Bombadil.Criteria.prepare_fuzzy(search_query),
      order_by: ^order_by
    )
  end

  defp to_tuple_list(search_query) do
    search_query
    |> Enum.map(fn element -> Enum.into(element, []) end)
    |> List.flatten()
  end
end
