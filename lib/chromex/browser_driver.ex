defmodule Chromex.BrowserDriver do
  alias Chromex.BrowserDriver.Server

  @spec start(keyword()) :: GenServer.on_start()
  def start(opts) do
    GenServer.start_link(Server, opts, name: Chromex.BrowserDriver)
  end

  @spec send(message :: map()) :: :ok | {:error, String.t()}
  def send(message) when is_map(message) do
    GenServer.call(Chromex.BrowserDriver, {:send, message})
  end
end
