import Config

config :bombadil, Bombadil.TestRepo,
  username: "postgres",
  password: "postgres",
  database: "bombadil_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :logger, level: :info
config :bombadil, ecto_repos: [Bombadil.TestRepo]

config :bombadil,
  table_name: "search_index",
  additional_fields: [{:test, :string}, {:item_id, :integer}]
