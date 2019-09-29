defmodule Bombadil.TestRepo do
  use Ecto.Repo,
    otp_app: :bombadil,
    adapter: Ecto.Adapters.Postgres
end
