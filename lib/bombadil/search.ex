defmodule Bombadil.Search do
  import Ecto.Query

  alias Bombadil.Ecto.Schema.SearchIndex

  # EXPLORE websearch
  # SELECT websearch_to_tsquery('english', '"supernovae stars" -crab');
  # TODO: Convert to opts the options ;)
  def search(search_query, operator \\ :or)

  def search(search_query, operator) when is_list(search_query) do
    search_query = to_tuple_list(search_query)
    construct_extact_match_query(search_query, operator)
  end

  def search(search_query, operator) when is_binary(search_query) do
    construct_extact_match_query(search_query, operator)
  end

  def fuzzy_search(search_query) when is_list(search_query) do
    search_query = to_tuple_list(search_query)
    construct_fuzzy_query(search_query)
  end

  def fuzzy_search(search_query) when is_binary(search_query) do
    construct_fuzzy_query(search_query)
  end

  defp construct_extact_match_query(search_query, operator) do
    queryable =
      from(i in SearchIndex,
        where: ^Bombadil.Criteria.prepare(search_query, operator)
      )

    Bombadil.Repo.all(queryable)
  end

  defp construct_fuzzy_query(search_query) do
    queryable =
      from(i in SearchIndex,
        where: ^Bombadil.Criteria.prepare_fuzzy(search_query)
      )

    Bombadil.Repo.all(queryable)
  end

  defp to_tuple_list(search_query) do
    search_query
    |> Enum.map(fn element -> Enum.into(element, []) end)
    |> List.flatten()
  end
end
