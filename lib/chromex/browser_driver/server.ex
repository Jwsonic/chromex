defmodule Chromex.BrowserDriver.Server do
  use GenServer

  alias Chromex.WebSocket
  alias Chromex.BrowserPort

  require Logger

  # Client methods

  def start_link(opts) when is_list(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  # Server callbacks

  @impl true
  def init(opts) do
    Process.flag(:trap_exit, true)

    with {:ok, port} <- BrowserPort.start(opts) do
      {:ok, %{port: port}}
    end
  end

  @spec send(msg :: map()) :: {:ok, map} | {:error, String.t()}
  def send(msg) do
    GenServer.call(__MODULE__, {:send, msg})
  end

  @impl true
  def handle_call({:send, msg}, _from, %{socket: socket} = state) when is_map(msg) do
    # TODO: Migrate to async socket + ID Manager
    reply =
      msg
      |> Map.update("id", 1, fn id -> id end)
      |> do_send(socket)

    {:reply, reply, state}
  end

  # Port Callbacks

  @impl true
  def handle_info({:ws_uri, ws_uri}, state) do
    {:ok, socket} = WebSocket.connect(ws_uri)

    {:noreply, %{state | socket: socket}}
  end

  @impl true
  def handle_info({:browser_exited, status}, state) do
    Logger.info("Browser closed with status: #{inspect(status)}.")

    {:stop, :browser_exited, state}
  end

  # Websocket callbacks

  @impl true
  def handle_info(:ws_connect, %{socket: socket} = state) do
    verify_devtools_version!(socket)

    {:noreply, state}
  end

  @impl true
  def handle_info({:ws_disconnect, _reason}, state) do
    {:stop, :browser_closed, state}
  end

  @impl true
  def handle_info({:ws_message, message}, state) do
    case Jason.decode(message) do
      {:ok, message} ->
        Logger.info("Got message: #{inspect(message)}")

      _ ->
        {:noreply, state}
    end
  end

  @impl true
  def handle_info(message, state) do
    Logger.info("Received unhandled message #{inspect(message)}.")

    {:noreply, state}
  end

  # Private methods

  @current_version "1.3"
  @version_message %{"id" => 1, "method" => "Browser.getVersion"}
  @close_message %{"id" => 1, "method" => "Browser.close"}

  defp verify_devtools_version!(socket) do
    case do_send(@version_message, socket) do
      {:ok, %{"result" => %{"protocolVersion" => @current_version}}} ->
        Logger.info("Devtools version match.")
        :ok

      _ ->
        do_send(@close_message, socket)

        raise(
          "Your chrome instance does not support devtools protocol version #{@current_version}."
        )
    end
  end

  defp do_send(%{"id" => id} = msg, socket) do
    Logger.info("Sending message: #{inspect(msg)}")

    msg
    |> Jason.encode!()
    |> (&WebSocket.send(socket, &1)).()

    receive do
      {:ws_message, %{"id" => ^id} = message} ->
        {:ok, message}
    after
      1_000 -> {:error, "Timed out."}
    end
  end
end
