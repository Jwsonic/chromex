defmodule Chromex.BrowserDriver do
  alias Chromex.BrowserDriver.Server

  @spec start(keyword()) :: GenServer.on_start()
  def start(opts) do
    GenServer.start_link(Server, opts, [])
  end

  @spec send(pid :: pid(), message :: map()) :: :ok | {:error, String.t()}
  def send(pid, message) when is_pid(pid) and is_map(message) do
    GenServer.call(pid, {:send, message})
  end
end
