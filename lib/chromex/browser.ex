defmodule Chromex.Browser do
  use GenServer

  alias Chromex.Socket

  require Logger

  # Client methods

  def start_link(opts) when is_list(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  # Server callbacks

  @default_state %{
    executable: "chromium",
    port: 0,
    data_dir: "chromex",
    headless: false
  }

  @impl true
  def init(opts) do
    Process.flag(:trap_exit, true)

    port =
      opts
      |> Enum.into(@default_state)
      |> find_execuatble!()
      |> verify_data_dir!()
      |> build_args!()
      |> spawn_browser!()

    {:ok, %{port: port}}
  end

  @spec send(msg :: map()) :: map() | :ok
  def send(msg) do
    GenServer.call(__MODULE__, {:send, msg})
  end

  @impl true
  def handle_call({:send, msg}, _from, %{socket: socket} = state) when is_map(msg) do
    reply =
      msg
      |> Map.update("id", 1, fn id -> id end)
      |> do_send(socket)

    {:reply, reply, state}
  end

  # Port Callbacks

  @impl true
  def handle_info({port, {:exit_status, status}}, %{port: port} = state) do
    Logger.warn("Browser exited with status: #{status}.")

    {:noreply, %{state | port: nil}}
  end

  @impl true
  def handle_info({port, {:data, {:eol, ""}}}, %{port: port} = state) do
    {:noreply, state}
  end

  @impl true
  def handle_info(
        {port, {:data, {:eol, "DevTools listening on " <> ws_address}}},
        %{port: port} = state
      ) do
    Logger.info("Connecting to chrome on #{ws_address}.")

    {:ok, socket} = Socket.connect(ws_address)

    verify_devtools_version!(socket)

    {:noreply, Map.put(state, :socket, socket)}
  end

  @impl true
  def handle_info({port, {:data, {:eol, data}}}, %{port: port} = state) do
    Logger.info("Received data: #{inspect(data)}.")

    {:noreply, state}
  end

  # Websocket callbacks

  @impl true
  def handle_info({:ws_message, message}, state) do
    Logger.info("Message from chrome: #{inspect(message)}.")

    {:noreply, state}
  end

  @impl true
  def handle_info({:EXIT, _pid, :closed}, state) do
    Logger.info("Websocket closed")

    {:stop, :closed, state}
  end

  @impl true
  def handle_info(message, state) do
    Logger.info("Received unhandled message #{inspect(message)}.")

    {:noreply, state}
  end

  # Private methods

  defp find_execuatble!(%{executable: executable} = config) do
    case System.find_executable(executable) do
      nil -> raise "Could not find #{executable} in your path."
      executable -> %{config | executable: executable}
    end
  end

  defp verify_data_dir!(%{data_dir: data_dir} = state) when is_bitstring(data_dir) do
    data_dir =
      case Path.type(data_dir) do
        :absolute ->
          data_dir

        _ ->
          System.tmp_dir!() |> Path.join(data_dir)
      end

    if not File.exists?(data_dir), do: File.mkdir!(data_dir)

    Map.put(state, :data_dir, data_dir)
  end

  defp build_args!(%{port: port, data_dir: data_dir} = config)
       when is_number(port) and is_bitstring(data_dir) do
    args = [
      "--no-first-run",
      "--no-default-browser-check",
      "--remote-debugging-port=#{port}",
      "--user-data-dir=#{data_dir}"
    ]

    args =
      case Map.get(config, :headless, true) do
        true -> ["--headless" | args]
        _ -> args
      end

    Map.put(config, :args, args)
  end

  @wrapper_script "chrome_wrapper.sh"

  defp spawn_browser!(%{args: args, executable: executable}) do
    wrapper_script = :chromex |> :code.priv_dir() |> Path.join(@wrapper_script)

    port =
      Port.open({:spawn_executable, wrapper_script}, [
        :binary,
        :exit_status,
        :stderr_to_stdout,
        line: 10_000,
        args: [executable | args]
      ])

    Port.monitor(port)

    port
  end

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
    |> (&Socket.send(socket, &1)).()

    receive do
      {:ws_message, %{"id" => ^id} = message} ->
        {:ok, message}
    after
      1_000 -> {:error, "Timed out"}
    end
  end
end
