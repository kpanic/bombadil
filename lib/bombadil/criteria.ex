defmodule Bombadil.Criteria do
  @moduledoc false

  require Ecto.Query.API
  import Ecto.Query, only: [dynamic: 1]

  def prepare(payload, exclusive \\ :or)

  def prepare(payload, :or) when is_list(payload) do
    Enum.reduce(payload, dynamic(false), fn
      {key, value}, dynamic ->
        dynamic(^dynamic or ^prepare_fragment(key, value))
    end)
  end

  def prepare(payload, :and) when is_list(payload) do
    Enum.reduce(payload, dynamic(true), fn
      {key, value}, dynamic ->
        dynamic(^dynamic and ^prepare_fragment(key, value))
    end)
  end

  def prepare(query, _operator) when is_binary(query) do
    dynamic(
      fragment(
        "to_tsvector('simple', payload::text) @@ plainto_tsquery('simple', ?)",
        ^query
      )
    )
  end

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

  def prepare_fragment(key, value) do
    dynamic(
      fragment(
        "to_tsvector('simple', (payload->?)::text) @@ plainto_tsquery('simple', ?)",
        ^key,
        ^"#{value}"
      )
    )
  end
end
