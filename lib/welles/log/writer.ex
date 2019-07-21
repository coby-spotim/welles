defmodule Welles.Log.Writer do
  @moduledoc """
  The writing module for the Welles append only log.
  """

  use GenServer

  ## Client

  @doc """
  Create a new log.
  """
  @spec start_link(Keyword.t()) :: GenServer.on_start()
  def start_link(opts) do
    {name, _opts} = Keyword.pop(opts, :name, __MODULE__)

    GenServer.start_link(__MODULE__, [],
      name: {:via, Registry, {Registry.Welles, [:writer, name]}}
    )
  end

  @doc """
  Adds an event to the specified log.
  """
  @spec add_event(String.t(), String.t()) :: :ok | {:error, :not_found}
  def add_event(log, event) do
    case Registry.lookup(Registry.Welles, [:writer, log]) do
      [] -> {:error, :not_found}
      [{pid, _value}] -> GenServer.cast(pid, {:add, event})
    end
  end

  @doc """
  Reads the current list of events in the specified log.
  """
  @spec read(binary) :: [String.t()] | {:error, :not_found}
  def read(log) do
    case Registry.lookup(Registry.Welles, [:writer, log]) do
      [] -> {:error, :not_found}
      [{pid, _value}] -> GenServer.call(pid, :read)
    end
  end

  ## Server

  @spec init([]) :: {:ok, []}
  def init([]) do
    {:ok, []}
  end

  def handle_cast({:add, event}, state) do
    {:noreply, [event | state]}
  end

  def handle_call(:read, _from, state) do
    {:reply, state, []}
  end
end
