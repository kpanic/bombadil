defmodule Bombadil.Repo.Migrations.CreateTrigramExtension do
  use Ecto.Migration

  def up do
    execute("CREATE extension if not exists pg_trgm;")
  end

  def down do
    execute("drop extension pg_trgm;")
  end
end
