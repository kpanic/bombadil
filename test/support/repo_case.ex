defmodule Bombadil.RepoCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Bombadil.TestRepo

      import Ecto
      import Ecto.Query
      import Bombadil.RepoCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Bombadil.TestRepo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Bombadil.TestRepo, {:shared, self()})
    end

    :ok
  end
end
