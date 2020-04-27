defmodule Chromex.Browser do
  use GenServer

  require Logger

  # Client methods

  def start_link(opts) when is_list(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  # Server callbacks

  @default_config %{
    executable: "chromium",
    port: "9222",
    data_dir: "chromex"
  }

  @impl true
  def init(opts) do
    state =
      opts
      |> Enum.into(@default_config)
      |> build_args!()
      |> find_execuatble!()
      |> spawn_browser!()

    {:ok, state}
  end

  @impl true
  def handle_info({_port, {:exit_status, status}}, state) do
    Logger.warn("Browser exited with status: #{status}.")

    {:noreply, %{state | port: nil}}
  end

  @impl true
  def handle_info({_port, {:data, {:eol, "DevTools listening on " <> ws_address}}}, state) do
    Logger.info("Connecting to chrome on '#{ws_address}'.")

    {:noreply, state}
  end

  @impl true
  def handle_info({_port, {:data, {:eol, data}}}, state) do
    Logger.info("Received data: #{inspect(data)}.")

    {:noreply, state}
  end

  @impl true
  def handle_info({_port, message}, state) do
    Logger.info("Received unhandled message #{message}.")

    {:noreply, state}
  end

  # Private methods

  defp build_args!(%{port: port, data_dir: data_dir} = config)
       when is_bitstring(port) and is_bitstring(data_dir) do
    data_dir =
      case Path.type(data_dir) do
        :absolute ->
          data_dir

        _ ->
          System.tmp_dir!() |> Path.join(data_dir)
      end

    if not File.exists?(data_dir), do: File.mkdir!(data_dir)

    args = [
      "--no-first-run",
      "--no-default-browser-check",
      "--remote-debugging-port=#{port}",
      "--user-data-dir=#{data_dir}"
    ]

    Map.put(config, :args, args)
  end

  defp find_execuatble!(%{executable: executable} = config) do
    case System.find_executable(executable) do
      nil -> raise "Could not find #{executable} in your path."
      executable -> %{config | executable: executable}
    end
  end

  defp spawn_browser!(%{args: args, executable: executable} = config) do
    port =
      Port.open({:spawn_executable, executable}, [
        :binary,
        :exit_status,
        :stderr_to_stdout,
        line: 10_000,
        args: args
      ])

    Map.put(config, :port, port)
  end
end
