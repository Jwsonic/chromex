defmodule Chromex.DevtoolsProtocol.Profiler do
  @moduledoc """
    
  """

  # Profile node. Holds callsite information, execution statistics and child nodes.
  @type profile_node :: %{
          required(:id) => integer(),
          required(:callFrame) => Runtime.call_frame(),
          optional(:hitCount) => integer(),
          optional(:children) => [integer()],
          optional(:deoptReason) => String.t(),
          optional(:positionTicks) => [position_tick_info()]
        }

  # Profile.
  @type profile :: %{
          required(:nodes) => [profile_node()],
          required(:startTime) => integer() | float(),
          required(:endTime) => integer() | float(),
          optional(:samples) => [integer()],
          optional(:timeDeltas) => [integer()]
        }

  # Specifies a number of samples attributed to a certain source position.
  @type position_tick_info :: %{required(:line) => integer(), required(:ticks) => integer()}

  # Coverage data for a source range.
  @type coverage_range :: %{
          required(:startOffset) => integer(),
          required(:endOffset) => integer(),
          required(:count) => integer()
        }

  # Coverage data for a JavaScript function.
  @type function_coverage :: %{
          required(:functionName) => String.t(),
          required(:ranges) => [coverage_range()],
          required(:isBlockCoverage) => boolean()
        }

  # Coverage data for a JavaScript script.
  @type script_coverage :: %{
          required(:scriptId) => Runtime.script_id(),
          required(:url) => String.t(),
          required(:functions) => [function_coverage()]
        }

  # Describes a type collected during runtime.
  @type type_object :: %{required(:name) => String.t()}

  # Source offset and types for a parameter or return value.
  @type type_profile_entry :: %{
          required(:offset) => integer(),
          required(:types) => [type_object()]
        }

  # Type profile data collected during runtime for a JavaScript script.
  @type script_type_profile :: %{
          required(:scriptId) => Runtime.script_id(),
          required(:url) => String.t(),
          required(:entries) => [type_profile_entry()]
        }

  # Collected counter information.
  @type counter_info :: %{required(:name) => String.t(), required(:value) => integer()}

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
