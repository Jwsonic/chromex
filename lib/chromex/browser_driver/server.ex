defmodule Chromex.BrowserDriver.Server do
  use GenServer

  alias Chromex.WebSocket
  alias Chromex.BrowserPort
  alias Chromex.BrowserDriver.MessageId

  require Logger

  @impl true
  def init(opts) do
    Process.flag(:trap_exit, true)

    with {:ok, _pid} <- MessageId.start_link(),
         {:ok, port} <- BrowserPort.start_link(opts) do
      {:ok, %{port: port, socket: nil}}
    end
  end

  @impl true
  def handle_call({:send, message}, {from, _call}, %{socket: socket} = state)
      when is_map(message) do
    id = MessageId.next()
    message = Map.put(message, :id, id)

    MessageId.subscribe(id, from)

    reply = WebSocket.send(socket, message)

    {:reply, reply, state}
  end

  # Port Callbacks

  @impl true
  def handle_info({:browser_started, ws_uri}, state) do
    {:ok, socket} = WebSocket.connect(ws_uri)

    {:noreply, %{state | socket: socket}}
  end

  @impl true
  def handle_info({:browser_exited, status}, state) do
    Logger.info("Browser closed with status: #{inspect(status)}.")

    {:stop, :browser_exited, state}
  end

  # Websocket callbacks

  @devtools_version "1.3"
  @version_message %{"id" => 1, "method" => "Browser.getVersion"}

  @impl true
  def handle_info(:ws_connect, %{port: port, socket: socket} = state) do
    do_send(socket, @version_message, self())

    receive do
      {:ws_message, %{"result" => %{"protocolVersion" => @devtools_version}}} ->
        {:noreply, state}

      {:ws_message, %{"result" => %{"protocolVersion" => version}}} ->
        BrowserPort.close(port)

        {:stop, "Incompatible DevTools version: #{version}.", state}
    after
      5_000 ->
        BrowserPort.close(port)

        {:stop, "DevTools version check timed out.", state}
    end
  end

  @impl true
  def handle_info({:ws_disconnect, _reason}, state) do
    {:stop, :browser_closed, state}
  end

  @impl true
  def handle_info({:ws_message, %{"id" => id}}, state) do
    with {:ok, listener} <- MessageId.listener(id) do
      Process.send(listener, {:browser_message}, [])
    end

    {:noreply, state}
  end

  @impl true
  def handle_info(message, state) do
    Logger.info("Received unhandled message #{inspect(message)}.")

    {:noreply, state}
  end

  defp do_send(socket, message, listener)
       when is_pid(socket) and is_map(message) and is_pid(listener) do
    id = MessageId.next()
    message = Map.put(message, :id, id)

    MessageId.subscribe(id, listener)

    WebSocket.send(socket, message)
  end
end
