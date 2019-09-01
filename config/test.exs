use Mix.Config

config :bombadil, Bombadil.Repo,
  username: "postgres",
  password: "postgres",
  database: "bombadil_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :logger, level: :info

config :bombadil,
  table_name: "search_index",
  additional_fields: [{:test, :string}]
