defmodule Chromex.BrowserDriver do
  alias Chromex.BrowserDriver.Server

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    GenServer.start_link(Server, opts, name: Chromex.BrowserDriver)
  end

  @spec send(msg :: map()) :: :ok | {:error, Jason.EncodeError.t() | Exception.t()}
  def send(msg) do
    GenServer.call(Chromex.BrowserDriver, {:send, msg})
  end
end
