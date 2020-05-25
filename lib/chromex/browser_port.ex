defmodule Chromex.BrowserPort do
  alias Chromex.BrowserPort.Server

  @spec start_link(opts :: keyword()) :: GenServer.on_start()
  def start_link(opts) do
    opts = Keyword.put(opts, :stream_to, self())

    GenServer.start_link(Server, opts, [])
  end

  @spec close(pid :: pid()) :: true
  def close(pid) when is_pid(pid) do
    GenServer.call(pid, :close)
  end
end
