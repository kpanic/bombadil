defmodule Bombadil.Repo.Migrations.CreateTrigramExtension do
  use Ecto.Migration

  def up do
    execute("CREATE extension if not exists pg_trgm;")
  end

  def down do
    execute("DROP INDEX users_username_trgm_index;")
  end
end
