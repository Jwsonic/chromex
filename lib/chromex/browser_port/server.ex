defmodule Chromex.BrowserPort.Server do
  use GenServer

  require Logger

  @default_opts %{
    executable: "chromium",
    port: 0,
    data_dir: "chromex",
    headless: false
  }

  @impl true
  def init(opts) do
    stream_to = Keyword.get(opts, :stream_to)

    port =
      opts
      |> Enum.into(@default_opts)
      |> find_execuatble!()
      |> verify_data_dir!()
      |> build_args!()
      |> spawn_browser!()

    {:ok, %{port: port, stream_to: stream_to, ws_uri: nil}}
  end

  @impl true
  def handle_call(:close, _from_pid, %{port: port} = state) do
    {:reply, Port.close(port), state}
  end

  @impl true
  def handle_info({port, {:exit_status, status}}, %{port: port, stream_to: stream_to} = state) do
    Process.send(stream_to, {:browser_exited, status}, [:noconnect])

    {:noreply, %{state | port: nil}}
  end

  @impl true
  def handle_info(
        {port, {:data, {:eol, "DevTools listening on " <> ws_uri}}},
        %{port: port, stream_to: stream_to} = state
      ) do
    Process.send(stream_to, {:browser_started, ws_uri}, [:noconnect])

    {:noreply, %{state | ws_uri: ws_uri}}
  end

  @impl true
  def handle_info({port, {:data, {:eol, _data}}}, %{port: port} = state) do
    {:noreply, state}
  end

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
    wrapper_script =
      :chromex |> :code.priv_dir() |> Path.join(@wrapper_script) |> String.to_charlist()

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
end
