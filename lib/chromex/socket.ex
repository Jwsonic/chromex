defmodule Chromex.Socket do
  use GenServer

  require Logger

  # API methods

  def connect(uri) when is_bitstring(uri) do
    GenServer.start_link(__MODULE__, stream_to: self(), uri: uri)
  end

  def send(pid, message) when is_pid(pid) and is_bitstring(message) do
    GenServer.cast(pid, {:send, message})
  end

  @impl true
  def init(args) do
    uri = args |> Keyword.get(:uri, "") |> URI.parse()
    stream_to = Keyword.get(args, :stream_to)

    with {:ok, gun_pid} <- open(uri),
         {:ok, ref} <- upgrade(gun_pid, uri) do
      {:ok, %{gun_pid: gun_pid, ref: ref, stream_to: stream_to}}
    else
      {:error, message} -> {:stop, message}
    end
  end

  @impl true
  def handle_cast({:send, message}, %{gun_pid: gun_pid} = state) when is_bitstring(message) do
    :gun.ws_send(gun_pid, {:text, message})

    {:noreply, state}
  end

  @impl true
  def handle_info(
        {:gun_ws, gun_pid, ref, frame},
        %{gun_pid: gun_pid, ref: ref, stream_to: stream_to} = state
      ) do
    case frame do
      {:text, message} ->
        case Jason.decode(message) do
          {:ok, data} ->
            Process.send(stream_to, {:ws_message, data}, [])

          {:error, _reason} ->
            Process.send(stream_to, {:ws_message, message}, [])
        end

      frame ->
        Logger.info("Received WS frame: #{inspect(frame)}.")
    end

    {:noreply, state}
  end

  @impl true
  def handle_info({:gun_up, _pid, :http}, state) do
    # This will occasionally fire but does not seem to affect the websocket.

    {:noreply, state}
  end

  @impl true
  def handle_info({:gun_down, _pid, :http, :closed, _status, _headers}, state) do
    # This will occasionally fire but does not seem to affect the websocket.

    {:noreply, state}
  end

  def handle_info({:gun_down, _pid, :ws, :closed, _status, _headers}, state) do
    {:stop, :closed, state}
  end

  @impl true
  def handle_info(message, state) do
    Logger.info("WS message: #{inspect(message)}.")

    {:noreply, state}
  end

  # Private methods

  defp open(%URI{host: host, port: port}) do
    host
    |> String.to_charlist()
    |> :gun.open(port)
  end

  defp upgrade(gun_pid, %URI{path: path}) do
    ref = :gun.ws_upgrade(gun_pid, path)

    receive do
      {:gun_upgrade, ^gun_pid, ^ref, ["websocket"], _headers} ->
        {:ok, ref}

      {:gun_response, ^gun_pid, ^ref, _is_final, _status, _headers} ->
        {:error, "Socket upgrade failed."}

      {:gun_error, ^gun_pid, ^ref, reason} ->
        {:error, reason}
    after
      5_000 ->
        {:error, "Timed out."}
    end
  end
end
