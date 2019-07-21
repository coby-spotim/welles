defmodule Welles.Log.Persister do
  @moduledoc """
  The persistence module for the Welles append only log.
  """

  use GenServer
  alias Welles.Log

  ## Client

  @doc """
  Create a new log.
  """
  @spec start_link(Keyword.t()) :: GenServer.on_start()
  def start_link(opts) do
    {name, _opts} = Keyword.pop(opts, :name, __MODULE__)

    GenServer.start_link(__MODULE__, name,
      name: {:via, Registry, {Registry.Welles, [:persister, name]}}
    )
  end

  ## Server

  @spec init(binary) :: {:ok, {binary, File.io_device()}}
  def init(log_name) do
    file_name = Path.join(logs_directory(), log_name)
    file = File.open!(file_name, [:append])
    schedule_work()
    {:ok, {log_name, file}}
  end

  def handle_info(:write, {log_name, _file} = state) do
    case Log.Writer.read(log_name) do
      {:error, :not_found} -> {:stop, :no_log_found, nil}
      events -> write_to_file(events, state)
    end
  end

  @spec write_to_file(list, {binary, File.io_device()}) :: {:noreply, {binary, File.io_device()}}
  defp write_to_file(events, state) when length(events) < 1 do
    schedule_work()
    {:noreply, state}
  end

  defp write_to_file(events, {_log_name, file} = state) do
    events
    |> Enum.reverse()
    |> Enum.each(&IO.write(file, [&1, "\n"]))

    schedule_work()
    {:noreply, state}
  end

  @spec schedule_work() :: reference
  defp schedule_work, do: Process.send_after(self(), :write, write_interval())
  @spec write_interval() :: non_neg_integer
  defp write_interval, do: Application.get_env(:welles, :write_interval, 1_000)

  @spec logs_directory() :: String.t()
  defp logs_directory do
    logs_dir = Application.get_env(:welles, :logs_directory, "logs")

    unless File.exists?(logs_dir) do
      File.mkdir!(logs_dir)
    end

    logs_dir
  end
end
