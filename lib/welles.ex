defmodule Welles do
  @moduledoc """
  An append only log example inspired by [Apache Kafka](https://kafka.apache.org/)
  """

  alias Welles.LogWriter

  @typedoc "Values returned for when a log is created"
  @type on_create :: {:ok, :created | :already_created} | {:error, any}
  @typedoc "Values returned for when an event is added to a log"
  @type on_new_event :: :added | :not_found

  @doc """
  Creates a new log with the specified name.

  ### Examples
  In the following example we create a log with the name "my_log",
  then try to create another log with the same name and see that `:already_created` is returned.

      iex> Welles.create_log("my_log")
      {:ok, :created}
      iex> Welles.create_log("my_log")
      {:ok, :already_created}

  ### Return Values
  If the log is created normally, `{:ok, :created}` is returned.
  If a log with the same name has already been created, `{:ok, :already_created}` is returned.
  If an error occurs when trying to start the log, `{:error, reason}` is returned.
  """
  @spec create_log(String.t()) :: on_create
  def create_log(name) do
    case LogWriter.create(name: name) do
      {:ok, _pid} -> {:ok, :created}
      {:error, {:already_started, _pid}} -> {:ok, :already_created}
      error -> error
    end
  end

  @doc """
  Adds an event to the specified log.

  ### Examples
  In the following example we create a log with the name "my_log",
  then add an event to it.

      iex> Welles.create_log("my_log")
      {:ok, :created}
      iex> Welles.add_event("my_event", "my_log")
      :added

  In the next example we attempt to add an event to a log that doesn't exist.

      iex> Welles.add_event("my_event", "my_log")
      :not_found

  ### Return Values
  If the event is added to the log, `:added` is returned.
  If the log that you are trying to add to doesn't exist, `:not_found` is returned.
  """
  @spec add_event(binary, String.t()) :: on_new_event
  def add_event(event, log_name) do
    case LogWriter.add_event(event, log_name) do
      :ok -> :added
      {:error, :not_found} -> :not_found
    end
  end
end
