defmodule Chromex.WebSocket do
  alias Chromex.WebSocket.Server

  @spec connect(uri :: String.t()) :: GenServer.on_start()
  def connect(uri) when is_bitstring(uri) do
    GenServer.start_link(Server, stream_to: self(), uri: uri)
  end

  @spec send(pid :: pid(), message :: map()) ::
          :ok | {:error, Jason.EncodeError.t() | Exception.t()}
  def send(pid, message) when is_pid(pid) and is_map(message) do
    with {:ok, message} <- Jason.encode(message) do
      GenServer.cast(pid, {:send, message})
    end
  end
end
