defmodule Bombadil.Repo.Migrations.CreateCustomSearchIndex do
  use Ecto.Migration
  require Bombadil.Ecto.DynamicMigration

  def change do
    Bombadil.Ecto.DynamicMigration.run()
  end
end
