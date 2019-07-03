defmodule Welles do
  @moduledoc """
  An append only log example inspired by [Apache Kafka](https://kafka.apache.org/)
  """

  alias Welles.Log

  @doc """
  Creates a new log with the specified name.

  ### Examples
  In the following example we create a log with the name "my_log",
  then try to create another log with the same name and see that `:already_created` is returned.

      iex> Welles.create_log("my_log")
      {:ok, :created}
      iex> Welles.create_log("my_log")
      {:ok, :already_created}
  """
  @spec create_log(String.t()) :: Log.on_create()
  def create_log(name) do
    Log.create_log(name)
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
  """
  @spec add_event(binary, String.t()) :: Log.on_new_event()
  def add_event(event, log_name) do
    Log.add_event(event, log_name)
  end
end
