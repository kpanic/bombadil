defmodule Bombadil.Repo do
  @moduledoc false

  use Ecto.Repo,
    otp_app: :bombadil,
    adapter: Ecto.Adapters.Postgres

  def init(_type, _config) do
    :ok = DeferredConfig.populate(:bombadil)
    updated_config = Application.get_env(:bombadil, Bombadil.Repo)
    {:ok, updated_config}
  end
end
