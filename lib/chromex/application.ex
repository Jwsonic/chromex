defmodule Chromex.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [
      Chromex.Browser
    ]

    opts = [strategy: :one_for_one, name: Chromex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end