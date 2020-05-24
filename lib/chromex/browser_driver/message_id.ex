defmodule Chromex.BrowserDriver.MessageId do
  use Agent

  @type t() :: non_neg_integer()

  @table __MODULE__
  @initial_id 1

  @spec start() :: Agent.on_start()
  def start do
    :ets.new(@table, [:set, :protected, :named_table])

    Agent.start_link(fn -> @initial_id end, name: __MODULE__)
  end

  @spec next() :: t()
  def next() do
    Agent.get_and_update(__MODULE__, fn id -> {id, id + 1} end)
  end

  @spec subscribe(id :: t(), listener :: pid()) :: :ok
  def subscribe(id, listener) do
    :ets.insert(@table, {id, listener})

    :ok
  end

  @spec listener(id :: t()) :: pid() | :none
  def listener(id) when is_integer(id) do
    case :ets.lookup(@table, id) do
      [{^id, pid}] -> pid
      _ -> :none
    end
  end
end
