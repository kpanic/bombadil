defmodule Bombadil.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {Bombadil.Repo, []}
    ]

    opts = [strategy: :one_for_one, name: Bombadil.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
