defmodule Chromex.WebSocket.Server do
  use GenServer

  require Logger

  @impl true
  def init(args) do
    uri = args |> Keyword.get(:uri, "") |> URI.parse()
    stream_to = Keyword.get(args, :stream_to)

    case open(uri) do
      {:ok, gun_pid} ->
        ref = upgrade(gun_pid, uri)

        {:ok, %{gun_pid: gun_pid, ref: ref, stream_to: stream_to}}

      {:error, message} ->
        {:stop, message}
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
          {:ok, message} ->
            Process.send(stream_to, {:ws_message, message}, [])
          _ ->
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

  def handle_info(
        {:gun_upgrade, gun_pid, ref, ["websocket"], _headers},
        %{gun_pid: gun_pid, ref: ref, stream_to: stream_to} = state
      ) do
    Process.send(stream_to, {:ws_connect, :socket_closed}, [])
    {:noreply, state}
  end

  @impl true
  def handle_info(
        {:gun_down, gun_pid, :ws, :closed, _status, _headers},
        %{gun_pid: gun_pid, stream_to: stream_to} = state
      ) do
    Process.send(stream_to, {:ws_disconnect, :socket_closed}, [])

    {:stop, :socket_closed, state}
  end

  @impl true
  def handle_info(
        {:gun_response, gun_pid, ref, _is_final, _status, _headers},
        %{gun_pid: gun_pid, ref: ref, stream_to: stream_to} = state
      ) do
    Process.send(stream_to, {:ws_disconnect, :upgrade_failed}, [])

    {:stop, :socket_closed, state}
  end

  @impl true
  def handle_info(
        {:gun_error, gun_pid, ref, reason},
        %{gun_pid: gun_pid, ref: ref, stream_to: stream_to} = state
      ) do
    Process.send(stream_to, {:ws_disconnect, reason}, [])

    {:stop, :socket_closed, state}
  end

  @impl true
  def handle_info(message, state) do
    Logger.info("WS message: #{inspect(message)}.")

    {:noreply, state}
  end

  defp open(%URI{host: host, port: port}) do
    host
    |> String.to_charlist()
    |> :gun.open(port)
  end

  defp upgrade(gun_pid, %URI{path: path}) do
    :gun.ws_upgrade(gun_pid, path)
  end
end
