# Bombadil 

![Lord of the rings, Tom Bombadil](/img/ring.png)

## You know, for (PostgreSQL) search

Bombadil is a wrapper around some PostgreSQL search capabilities.

It supports exact match through PostgreSQL tsvector(s) and fuzzy search inside
jsonb fields.

**This is a working proof of concept ;) I plan to iterate and improve it. If you want to contribute you are welcome!**

# Installation

The package can be installed by adding bombadil to your list of dependencies in mix.exs:

```elixir
def deps do
  [
    {:bombadil, "~> 0.1"}
  ]
end
```

Documentation is at https://hexdocs.pm/bombadil

# Preparation

```elixir
# Create and migrate the "search_index" table
mix do ecto.create, ecto.migrate
```

# Basic Usage

## (Almost) Exact match of an indexed word or sequence of words

```elixir
# Full string provided
alias Bombadil.Ecto.Schema.SearchIndex

iex> Bombadil.index(SearchIndex, payload: %{"book" => "Lord of the Rings"})
# Raw SQL: INSERT INTO "search_index" ("payload") VALUES ('{"book": "Lord of the Rings"}')
:ok
iex> Bombadil.search("Lord of the Rings")
# Raw SQL: SELECT s0."id", s0."payload" FROM "search_index" AS s0 WHERE (to_tsvector('simple', payload::text) @@ plainto_tsquery('simple', 'Lord of the Rings'))
[
  %Bombadil.Ecto.Schema.SearchIndex{
    __meta__: #Ecto.Schema.Metadata<:loaded, "search_index">,
    payload: %{"book" => "Lord of the Rings"},
    id: 1
  }
]

# One word provided (treated as case-insensitive)

iex> Bombadil.search("lord")
# Raw SQL: SELECT s0."id", s0."payload" FROM "search_index" AS s0 WHERE (to_tsvector('simple', payload::text) @@ plainto_tsquery('simple', 'lord'))
[
  %Bombadil.Ecto.Schema.SearchIndex{
    __meta__: #Ecto.Schema.Metadata<:loaded, "search_index">,
    payload: %{"book" => "Lord of the Rings"},
    id: 1
  }
]

# No results

iex> Bombadil.search("lordz")
# Raw SQL: SELECT s0."id", s0."payload" FROM "search_index" AS s0 WHERE (to_tsvector('simple', payload::text) @@ plainto_tsquery('simple', 'lordz'))
[]
```

## Fuzzy match

```elixir
iex> Bombadil.fuzzy_search(SearchIndex, "lord of the ringz")
# Raw SQL: SELECT s0."id", s0."payload" FROM "search_index" AS s0 WHERE (payload::text %> 'lord of the ringz')
[
  %Bombadil.Ecto.Schema.SearchIndex{
    __meta__: #Ecto.Schema.Metadata<:loaded, "search_index">,
    payload: %{"book" => "Lord of the Rings"},
    id: 1
  }
]

# No results

iex> Bombadil.fuzzy_search(SearchIndex, "lard of the ringz asdf")
# Raw SQL: SELECT s0."id", s0."payload" FROM "search_index" AS s0 WHERE (payload::text %> 'lord of the ringz asdf')
[]
```

# Match a specific field inside the indexed jsonb field

## (Almost) Exact match

```elixir
iex> Bombadil.index(SearchIndex, payload: %{"character" => "Tom Bombadil"})
:ok
iex> Bombadil.search([%{"book" => "rings"}])
# Raw SQL: SELECT s0."id", s0."payload" FROM "search_index" AS s0 WHERE (FALSE OR to_tsvector('simple', (payload->'book')::text) @@ plainto_tsquery('simple', 'rings'))
[
  %Bombadil.Ecto.Schema.SearchIndex{
    __meta__: #Ecto.Schema.Metadata<:loaded, "search_index">,
    payload: %{"book" => "Lord of the Rings"},
    id: 1
  }
]
iex> Bombadil.search([%{"character" => "bombadil"}])
# Raw SQL: SELECT s0."id", s0."payload" FROM "search_index" AS s0 WHERE (FALSE OR to_tsvector('simple', (payload->'character')::text) @@ plainto_tsquery('simple', 'bombadil'))
[
  %Bombadil.Ecto.Schema.SearchIndex{
    __meta__: #Ecto.Schema.Metadata<:loaded, "search_index">,
    payload: %{"character" => "Tom Bombadil"},
    id: 3
  }
]
```

## Fuzzy match
```elixir
iex> Bombadil.fuzzy_search(SearchIndex, [%{"book" => "lard"}])
# Raw SQL: SELECT s0."id", s0."payload" FROM "search_index" AS s0 WHERE (FALSE OR (payload->'book')::text %> 'lard')
[
  %Bombadil.Ecto.Schema.SearchIndex{
    __meta__: #Ecto.Schema.Metadata<:loaded, "search_index">,
    payload: %{"book" => "Lord of the Rings"},
    id: 1
  }
]
iex> Bombadil.fuzzy_search(SearchIndex, [%{"character" => "tom bomba"}])
# Raw SQL: SELECT s0."id", s0."payload" FROM "search_index" AS s0 WHERE (FALSE OR (payload->'character')::text %> 'tom bomba')
[
  %Bombadil.Ecto.Schema.SearchIndex{
    __meta__: #Ecto.Schema.Metadata<:loaded, "search_index">,
    payload: %{"character" => "Tom Bombadil"},
    id: 3
  }
]
iex> Bombadil.fuzzy_search(SearchIndex, [%{"book" => "tom"}])
# Raw SQL: SELECT s0."id", s0."payload" FROM "search_index" AS s0 WHERE (FALSE OR (payload->'book')::text %> 'tom bomba')
[]
```

# Matching search results with an additional context

Given a `search_index` that has also an `item_id` field as an additional context
for filtering, let's suppose you index also the `item_id` and you might have the
same `item_id` for another entry with different `payload` field like in this snippet:

```elixir

iex> Bombadil.index(SearchIndex, item_id: 42, payload: %{"ask" => "lord of the rings"})
iex> Bombadil.index(SearchIndex, item_id: 42, payload: %{"ask" => "I am hiding with the same id, don't find me!"})
```

You can apply a search and a context to filter a specific id, in this case `item_id` is `42`
and the payload that is "hiding" is filtered out.

```elixir
iex> Bombadil.fuzzy_search(SearchIndex, "lord of the ringz", context: %{item_id: 42})
[
  %Bombadil.Ecto.Schema.SearchIndex{
    __meta__: #Ecto.Schema.Metadata<:loaded, "search_index">,
    payload: %{"ask" => "lord of the rings"},
    id: 6,
    item_id: 42
  }
]
```

# Encoding to JSON

```elixir
iex> Bombadil.search("rings") |> Jason.encode!()
"[{\"payload\":{\"book\":\"Lord of the Rings\"}}]"
```

# Integration with your application

## Manual integration

### Define your schema

```elixir
defmodule YourApp.Ecto.Schema.SearchIndex do
  use Ecto.Schema

  @fields [:field1, :field2]
  @derive {Jason.Encoder, only: @fields}

  schema "your_table" do
    field(:payload, :map)
    field(:field1, :string)
    field(:field2, :string)
  end
end
```

### (optional) Define your schema with a different column name

If you want to use a different name for the `payload` field, you can define your schema in this way:

```elixir
defmodule YourApp.Ecto.Schema.SearchIndex do
  use Ecto.Schema

  schema "search_index" do
    field(:data, :map, source: :payload)
    field(:item_id, :integer)
  end
end
```

Notice how the:

```elixir
field(:data, :map, source: :payload)
```

specifies via the `field` macro another name for the `:payload` column

### Generate an Ecto migration

```bash
mix ecto.gen.migration create_search_index # For example
```


### Implement the migration

```elixir
defmodule YourApp.Repo.Migrations.CreateSearchIndex do
  use Ecto.Migration

  def change do
      create table("search_index") do
        add(:payload, :jsonb)
        add(:field1, :string)
        add(:field2, :string)
      end
  end
end
```

## Through configuration (via macros)

```elixir
config :bombadil, Bombadil.Repo,
  database: "your_database",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :bombadil,
  table_name: "search_index",
  additional_fields: [
    {:your_special_id, :string},
    [...]
  ]
```

### Generate an Ecto migration

```bash
mix ecto.gen.migration create_search_index # For example
```


### Wire the DynamicMigration based on your configuration

```elixir
defmodule YourApp.Repo.Migrations.CreateSearchIndex do
  use Ecto.Migration
  require Bombadil.Ecto.DynamicMigration

  def change do
    Bombadil.Ecto.DynamicMigration.run()
  end
end
```

### Run the migration

```elixir
mix ecto.migrate
```

And implement indexing and search for your use case by using the
`Bombadil.fuzzy_search/2` and `Bombadil.index/2` functions


# TODO

 [ ] Port user schema to `Bombadil.search`
