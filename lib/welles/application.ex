defmodule Welles.Application do
  @moduledoc false

  use Application

  @spec start(any, any) :: {:error, any} | {:ok, pid} | {:ok, pid, any}
  def start(_type, _args) do
    children = [
      {Registry, [keys: :unique, name: Registry.Welles]}
    ]

    opts = [strategy: :one_for_one, name: Welles.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
