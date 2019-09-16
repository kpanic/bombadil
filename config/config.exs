# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# third-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :bombadil, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:bombadil, :key)
#
# You can also configure a third-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#

config :bombadil, :ecto_repos, [Bombadil.Repo]

config :ecto, json_library: Jason

config :bombadil, Bombadil.Repo,
  database: {:system, "BOMBADIL_DATABASE_NAME", "bombadil"},
  username: {:system, "BOMBADIL_DATABASE_USERNAME", "postgres"},
  password: {:system, "BOMBADIL_DATABASE_PASSWORD", "postgres"},
  hostname: {:system, "BOMBADIL_DATABASE_HOST", "localhost"},
  otp_app: :bombadil

config :bombadil,
  table_name: "search_index",
  additional_fields: []

import_config "#{Mix.env()}.exs"
