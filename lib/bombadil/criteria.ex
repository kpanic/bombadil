defmodule Bombadil.Criteria do
  @moduledoc false

  require Ecto.Query.API
  import Ecto.Query, only: [dynamic: 1]

def prepare(payload, exclusive \\ :or)
def prepare(payload, mode) when is_list(payload) do
  cond do
    mode in [:or, :and] ->
      reducer = if mode == :or, do: dynamic(false), else: dynamic(true)
      fun = if mode == :or, do: fn {key, value}, dyn -> dynamic(^dyn or ^prepare_fragment(key, value)) end,
                                else: fn {key, value}, dyn -> dynamic(^dyn and ^prepare_fragment(key, value)) end
      Enum.reduce(payload, reducer, fun)
    mode in [:fulltext, :substring] ->
      # For list of maps, fallback to substring search for now (legacy behavior)
      Enum.reduce(payload, dynamic(false), fn {key, value}, dyn -> dynamic(^dyn or ^prepare_fragment(key, value)) end)
    true ->
      raise ArgumentError, "Unsupported mode for list payload: #{inspect(mode)}"
  end
end
def prepare(query, opts_or_operator) when is_binary(query) do
  case opts_or_operator do
    :fulltext ->
      dynamic(
        fragment(
          "to_tsvector('english', payload::text) @@ websearch_to_tsquery('english', ?)",
          ^query
        )
      )
    :substring ->
      dynamic(
        fragment(
          "(payload::text) ~~* ?",
          ^"%#{query}%"
        )
      )
    opts when is_list(opts) ->
      # Allow passing opts as a keyword list, e.g. [mode: :substring]
      case Keyword.get(opts, :mode, :fulltext) do
        :substring ->
          dynamic(
            fragment(
              "(payload::text) ~~* ?",
              ^"%#{query}%"
            )
          )
        _ ->
          dynamic(
            fragment(
              "to_tsvector('english', payload::text) @@ websearch_to_tsquery('english', ?)",
              ^query
            )
          )
      end
    _ ->
      dynamic(
        fragment(
          "to_tsvector('english', payload::text) @@ websearch_to_tsquery('english', ?)",
          ^query
        )
      )
  end
end
## Remove the extra def prepare/1, as the default is handled by the default argument in the main head

  def prepare_fuzzy(payload, exclusive \\ :or)

  def prepare_fuzzy(payload, :or) when is_list(payload) do
    Enum.reduce(payload, dynamic(false), fn
      {key, value}, dynamic ->
        dynamic(^dynamic or ^prepare_fuzzy(key, value))
    end)
  end

  def prepare_fuzzy(payload, :and) when is_list(payload) do
    Enum.reduce(payload, dynamic(true), fn
      {key, value}, dynamic ->
        dynamic(^dynamic and ^prepare_fuzzy(key, value))
    end)
  end

  def prepare_fuzzy(query, operator) when is_binary(query) and is_atom(operator) do
    dynamic(fragment("payload::text %> ?", ^query))
  end

  def prepare_fuzzy(key, value) when is_binary(key) and is_binary(value) do
    dynamic(fragment("(payload->?)::text %> ?", ^key, ^"#{value}"))
  end

  def order_by(search_query) when is_list(search_query) do
    Enum.flat_map(search_query, fn {key, value} ->
      [asc: dynamic(fragment("(payload->?)::text <-> ?", ^key, ^value))]
    end)
  end

  def order_by(search_query) when is_binary(search_query), do: []

  def prepare_fragment(key, value) do
    dynamic(
      fragment(
        "(payload->?)::text ~~* ?",
        ^key,
        ^"%#{value}%"
      )
    )
  end
end
