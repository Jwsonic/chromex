defmodule Chromex.DevtoolsProtocol.Profiler do
  @moduledoc """
   
  """

  # Coverage data for a source range.
  @type coverage_range :: String.t()

  # Coverage data for a JavaScript function.
  @type function_coverage :: String.t()

  # Specifies a number of samples attributed to a certain source position.
  @type position_tick_info :: String.t()

  # Profile.
  @type profile :: String.t()

  # Profile node. Holds callsite information, execution statistics and child nodes.
  @type profile_node :: String.t()

  # Coverage data for a JavaScript script.
  @type script_coverage :: String.t()

  @doc """
    
  """
  @spec disable(async: boolean()) :: %{}
  def disable(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    
  """
  @spec enable(async: boolean()) :: %{}
  def enable(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Collect coverage data for the current isolate. The coverage data may be incomplete due togarbage collection.
  """
  @spec get_best_effort_coverage(async: boolean()) :: %{}
  def get_best_effort_coverage(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Changes CPU profiler sampling interval. Must be called before CPU profiles recording started.
  """
  @spec set_sampling_interval(interval :: integer(), async: boolean()) :: %{}
  def set_sampling_interval(interval, opts \\ []) do
    msg = %{
      "interval" => interval
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    
  """
  @spec start(async: boolean()) :: %{}
  def start(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Enable precise code coverage. Coverage data for JavaScript executed before enabling precise codecoverage may be incomplete. Enabling prevents running optimized code and resets executioncounters.
  """
  @spec start_precise_coverage(
          call_count: boolean(),
          detailed: boolean(),
          allow_triggered_updates: boolean(),
          async: boolean()
        ) :: %{}
  def start_precise_coverage(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:call_count, :detailed, :allow_triggered_updates], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    
  """
  @spec stop(async: boolean()) :: %{}
  def stop(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Disable precise code coverage. Disabling releases unnecessary execution count records and allowsexecuting optimized code.
  """
  @spec stop_precise_coverage(async: boolean()) :: %{}
  def stop_precise_coverage(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Collect coverage data for the current isolate, and resets execution counters. Precise codecoverage needs to have started.
  """
  @spec take_precise_coverage(async: boolean()) :: %{}
  def take_precise_coverage(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  defp reduce_opts(keys, opts) do
    keys
    |> Enum.map(fn key -> {key, Keyword.get(opts, key, :missing)} end)
    |> Enum.reduce(%{}, fn
      {_key, :missing}, acc -> acc
      {key, value}, acc -> Map.put(acc, key, value)
    end)
  end
end
