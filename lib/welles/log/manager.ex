defmodule Welles.Log.Manager do
  @moduledoc false

  use Supervisor
  alias Welles.Log

  @spec start_link(keyword) :: Supervisor.on_start()
  def start_link(opts) do
    {name, _opts} = Keyword.pop(opts, :name, __MODULE__)

    Supervisor.start_link(__MODULE__, name,
      name: {:via, Registry, {Registry.Welles, [:supervisor, name]}}
    )
  end

  def init(log_name) do
    children = [
      {Log.Writer, [name: log_name]},
      {Log.Persister, [name: log_name]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
