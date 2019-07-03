defmodule Welles.Log.Manager do
  @moduledoc false

  use Supervisor

  @spec start_link(keyword) :: Supervisor.on_start()
  def start_link(opts) do
    {name, _opts} = Keyword.pop(opts, :name, __MODULE__)

    Supervisor.start_link(__MODULE__, name,
      name: {:via, Registry, {Registry.Welles, "#{name}_supervisor"}}
    )
  end

  def init(log_name) do
    children = [
      {Welles.Log.Writer, [name: "#{log_name}_writer"]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
