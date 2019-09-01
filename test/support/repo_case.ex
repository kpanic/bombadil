defmodule Bombadil.RepoCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Bombadil.Repo

      import Ecto
      import Ecto.Query
      import Bombadil.RepoCase

      # and any other stuff
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Bombadil.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Bombadil.Repo, {:shared, self()})
    end

    :ok
  end
end
