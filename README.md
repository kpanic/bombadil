# Bombadil 

![Lord of the rings, Tom Bombadil](/img/ring.png)

## You know, for (PostgreSQL) search

Bombadil is a wrapper around some PostgreSQL search capabilities.

It supports exact match through PostgreSQL tsvector(s) and fuzzy search inside
jsonb fields.

**This is a working proof of concept ;) I plan to iterate and improve it. If you have want to contribute you are welcome!**

# Preparation

```elixir
# Create and migrate the "search_index" table
mix do ecto.create, ecto.migrate
```

# Basic Usage

## (Almost) Exact match of an indexed word or sequence of words

```elixir
# Full string provided

iex> Bombadil.index(data: %{"book" => "Lord of the Rings"})
# Raw SQL: INSERT INTO "search_index" ("data") VALUES ('{"book": "Lord of the Rings"}')
:ok
iex> Bombadil.search("Lord of the Rings")
# Raw SQL: SELECT s0."id", s0."data" FROM "search_index" AS s0 WHERE (to_tsvector('simple', data::text) @@ plainto_tsquery('simple', 'Lord of the Rings'))
[
  %Bombadil.Ecto.Schema.SearchIndex{
    __meta__: #Ecto.Schema.Metadata<:loaded, "search_index">,
    data: %{"book" => "Lord of the Rings"},
    id: 1
  }
]

# One word provided (treated as case-insensitive)

iex> Bombadil.search("lord")
# Raw SQL: SELECT s0."id", s0."data" FROM "search_index" AS s0 WHERE (to_tsvector('simple', data::text) @@ plainto_tsquery('simple', 'lord'))
[
  %Bombadil.Ecto.Schema.SearchIndex{
    __meta__: #Ecto.Schema.Metadata<:loaded, "search_index">,
    data: %{"book" => "Lord of the Rings"},
    id: 1
  }
]

# No results

iex> Bombadil.search("lordz")
# Raw SQL: SELECT s0."id", s0."data" FROM "search_index" AS s0 WHERE (to_tsvector('simple', data::text) @@ plainto_tsquery('simple', 'lordz'))
[]
```

## Fuzzy match

```elixir
iex> Bombadil.fuzzy_search("lord of the ringz")
# Raw SQL: SELECT s0."id", s0."data" FROM "search_index" AS s0 WHERE (data::text %> 'lord of the ringz')
[
  %Bombadil.Ecto.Schema.SearchIndex{
    __meta__: #Ecto.Schema.Metadata<:loaded, "search_index">,
    data: %{"book" => "Lord of the Rings"},
    id: 1
  }
]

# No results

iex> Bombadil.fuzzy_search("lard of the ringz asdf")
# Raw SQL: SELECT s0."id", s0."data" FROM "search_index" AS s0 WHERE (data::text %> 'lord of the ringz asdf')
[]
```

# Match a specific field inside the indexed jsonb field

## (Almost) Exact match

```elixir
iex> Bombadil.index(data: %{"character" => "Tom Bombadil"})
:ok
iex> Bombadil.search([%{"book" => "rings"}])
# Raw SQL: SELECT s0."id", s0."data" FROM "search_index" AS s0 WHERE (FALSE OR to_tsvector('simple', (data->'book')::text) @@ plainto_tsquery('simple', 'rings'))
[
  %Bombadil.Ecto.Schema.SearchIndex{
    __meta__: #Ecto.Schema.Metadata<:loaded, "search_index">,
    data: %{"book" => "Lord of the Rings"},
    id: 1
  }
]
iex> Bombadil.search([%{"character" => "bombadil"}])
# Raw SQL: SELECT s0."id", s0."data" FROM "search_index" AS s0 WHERE (FALSE OR to_tsvector('simple', (data->'character')::text) @@ plainto_tsquery('simple', 'bombadil'))
[
  %Bombadil.Ecto.Schema.SearchIndex{
    __meta__: #Ecto.Schema.Metadata<:loaded, "search_index">,
    data: %{"character" => "Tom Bombadil"},
    id: 3
  }
]
```

## Fuzzy match
```elixir
iex> Bombadil.fuzzy_search([%{"book" => "lard"}])
# Raw SQL: SELECT s0."id", s0."data" FROM "search_index" AS s0 WHERE (FALSE OR (data->'book')::text %> 'lard')
[
  %Bombadil.Ecto.Schema.SearchIndex{
    __meta__: #Ecto.Schema.Metadata<:loaded, "search_index">,
    data: %{"book" => "Lord of the Rings"},
    id: 1
  }
]
iex> Bombadil.fuzzy_search([%{"character" => "tom bomba"}])
# Raw SQL: SELECT s0."id", s0."data" FROM "search_index" AS s0 WHERE (FALSE OR (data->'character')::text %> 'tom bomba')
[
  %Bombadil.Ecto.Schema.SearchIndex{
    __meta__: #Ecto.Schema.Metadata<:loaded, "search_index">,
    data: %{"character" => "Tom Bombadil"},
    id: 3
  }
]
iex> Bombadil.fuzzy_search([%{"book" => "tom"}])
# Raw SQL: SELECT s0."id", s0."data" FROM "search_index" AS s0 WHERE (FALSE OR (data->'book')::text %> 'tom bomba')
[]
```

# Encoding to JSON

```elixir
iex> Bombadil.search("rings") |> Jason.encode!()
"[{\"data\":{\"book\":\"Lord of the Rings\"}}]"
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
    field(:data, :map)
    field(:field1, :string)
    field(:field2, :string)
  end
end
```

**NOTE** that **data field** is mandatory at this stage

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
        add(:data, :jsonb)
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
`Bombadil.search/1` and `Bombadil.index/2` functions
