defmodule Chromex.DevtoolsProtocol.Debugger do
  @moduledoc """
    Debugger domain exposes JavaScript debugging capabilities. It allows setting and  removing breakpoints, stepping through execution, exploring stack traces, etc.
  """

  @type break_location :: String.t()

  # Breakpoint identifier.
  @type breakpoint_id :: String.t()

  # JavaScript call frame. Array of call frames form the call stack.
  @type call_frame :: String.t()

  # Call frame identifier.
  @type call_frame_id :: String.t()

  # Location in the source code.
  @type location :: String.t()

  # Scope description.
  @type scope :: String.t()

  # Enum of possible script languages.
  @type script_language :: String.t()

  # Search match for resource.
  @type search_match :: String.t()

  @doc """
    Continues execution until specific location is reached.
  """
  @spec continue_to_location(location :: location(),
          target_call_frames: String.t(),
          async: boolean()
        ) :: %{}
  def continue_to_location(location, opts \\ []) do
    msg = %{
      "location" => location
    }

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:target_call_frames], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Disables debugger for given page.
  """
  @spec disable(async: boolean()) :: %{}
  def disable(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Enables debugger for the given page. Clients should not assume that the debugging has beenenabled until the result for this command is received.
  """
  @spec enable(max_scripts_cache_size: integer() | float(), async: boolean()) :: %{}
  def enable(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:max_scripts_cache_size], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Evaluates expression on a given call frame.
  """
  @spec evaluate_on_call_frame(callFrameId :: call_frame_id(), expression :: String.t(),
          object_group: String.t(),
          include_command_line_api: boolean(),
          silent: boolean(),
          return_by_value: boolean(),
          generate_preview: boolean(),
          throw_on_side_effect: boolean(),
          async: boolean()
        ) :: %{}
  def evaluate_on_call_frame(call_frame_id, expression, opts \\ []) do
    msg = %{
      "callFrameId" => call_frame_id,
      "expression" => expression
    }

    async = Keyword.get(opts, :async, false)

    params =
      reduce_opts(
        [
          :object_group,
          :include_command_line_api,
          :silent,
          :return_by_value,
          :generate_preview,
          :throw_on_side_effect
        ],
        opts
      )

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Returns possible locations for breakpoint. scriptId in start and end range locations should bethe same.
  """
  @spec get_possible_breakpoints(start :: location(),
          end: location(),
          restrict_to_function: boolean(),
          async: boolean()
        ) :: %{}
  def get_possible_breakpoints(start, opts \\ []) do
    msg = %{
      "start" => start
    }

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:end_, :restrict_to_function], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Returns source for the script with given id.
  """
  @spec get_script_source(scriptId :: Runtime.script_id(), async: boolean()) :: %{}
  def get_script_source(script_id, opts \\ []) do
    msg = %{
      "scriptId" => script_id
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Stops on the next JavaScript statement.
  """
  @spec pause(async: boolean()) :: %{}
  def pause(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Removes JavaScript breakpoint.
  """
  @spec remove_breakpoint(breakpointId :: breakpoint_id(), async: boolean()) :: %{}
  def remove_breakpoint(breakpoint_id, opts \\ []) do
    msg = %{
      "breakpointId" => breakpoint_id
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Restarts particular call frame from the beginning.
  """
  @spec restart_frame(callFrameId :: call_frame_id(), async: boolean()) :: %{}
  def restart_frame(call_frame_id, opts \\ []) do
    msg = %{
      "callFrameId" => call_frame_id
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Resumes JavaScript execution.
  """
  @spec resume(terminate_on_resume: boolean(), async: boolean()) :: %{}
  def resume(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:terminate_on_resume], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Searches for given string in script content.
  """
  @spec search_in_content(scriptId :: Runtime.script_id(), query :: String.t(),
          case_sensitive: boolean(),
          is_regex: boolean(),
          async: boolean()
        ) :: %{}
  def search_in_content(script_id, query, opts \\ []) do
    msg = %{
      "scriptId" => script_id,
      "query" => query
    }

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:case_sensitive, :is_regex], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Enables or disables async call stacks tracking.
  """
  @spec set_async_call_stack_depth(maxDepth :: integer(), async: boolean()) :: %{}
  def set_async_call_stack_depth(max_depth, opts \\ []) do
    msg = %{
      "maxDepth" => max_depth
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Sets JavaScript breakpoint at a given location.
  """
  @spec set_breakpoint(location :: location(), condition: String.t(), async: boolean()) :: %{}
  def set_breakpoint(location, opts \\ []) do
    msg = %{
      "location" => location
    }

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:condition], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Sets JavaScript breakpoint at given location specified either by URL or URL regex. Once thiscommand is issued, all existing parsed scripts will have breakpoints resolved and returned in'locations' property. Further matching script parsing will result in subsequent'breakpointResolved' events issued. This logical breakpoint will survive page reloads.
  """
  @spec set_breakpoint_by_url(lineNumber :: integer(),
          url: String.t(),
          url_regex: String.t(),
          script_hash: String.t(),
          column_number: integer(),
          condition: String.t(),
          async: boolean()
        ) :: %{}
  def set_breakpoint_by_url(line_number, opts \\ []) do
    msg = %{
      "lineNumber" => line_number
    }

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:url, :url_regex, :script_hash, :column_number, :condition], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Activates / deactivates all breakpoints on the page.
  """
  @spec set_breakpoints_active(active :: boolean(), async: boolean()) :: %{}
  def set_breakpoints_active(active, opts \\ []) do
    msg = %{
      "active" => active
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Sets instrumentation breakpoint.
  """
  @spec set_instrumentation_breakpoint(instrumentation :: String.t(), async: boolean()) :: %{}
  def set_instrumentation_breakpoint(instrumentation, opts \\ []) do
    msg = %{
      "instrumentation" => instrumentation
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Defines pause on exceptions state. Can be set to stop on all exceptions, uncaught exceptions orno exceptions. Initial pause on exceptions state is 'none'.
  """
  @spec set_pause_on_exceptions(state :: String.t(), async: boolean()) :: %{}
  def set_pause_on_exceptions(state, opts \\ []) do
    msg = %{
      "state" => state
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Edits JavaScript source live.
  """
  @spec set_script_source(scriptId :: Runtime.script_id(), scriptSource :: String.t(),
          dry_run: boolean(),
          async: boolean()
        ) :: %{}
  def set_script_source(script_id, script_source, opts \\ []) do
    msg = %{
      "scriptId" => script_id,
      "scriptSource" => script_source
    }

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:dry_run], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Makes page not interrupt on any pauses (breakpoint, exception, dom exception etc).
  """
  @spec set_skip_all_pauses(skip :: boolean(), async: boolean()) :: %{}
  def set_skip_all_pauses(skip, opts \\ []) do
    msg = %{
      "skip" => skip
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Changes value of variable in a callframe. Object-based scopes are not supported and must bemutated manually.
  """
  @spec set_variable_value(
          scopeNumber :: integer(),
          variableName :: String.t(),
          newValue :: Runtime.call_argument(),
          callFrameId :: call_frame_id(),
          async: boolean()
        ) :: %{}
  def set_variable_value(scope_number, variable_name, new_value, call_frame_id, opts \\ []) do
    msg = %{
      "scopeNumber" => scope_number,
      "variableName" => variable_name,
      "newValue" => new_value,
      "callFrameId" => call_frame_id
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Steps into the function call.
  """
  @spec step_into(break_on_async_call: boolean(), async: boolean()) :: %{}
  def step_into(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:break_on_async_call], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Steps out of the function call.
  """
  @spec step_out(async: boolean()) :: %{}
  def step_out(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Steps over the statement.
  """
  @spec step_over(async: boolean()) :: %{}
  def step_over(opts \\ []) do
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
