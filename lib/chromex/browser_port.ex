defmodule Chromex.BrowserPort do
  alias Chromex.BrowserPort.Server

  @spec start(opts :: keyword()) :: GenServer.on_start()
  def start(opts) do
    GenServer.start_link(Server, opts, [])
  end

  @spec close(pid :: pid()) :: true
  def close(pid) when is_pid(pid) do
    GenServer.call(pid, :close)
  end
end
