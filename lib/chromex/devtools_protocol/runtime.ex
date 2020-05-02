defmodule Chromex.DevtoolsProtocol.Runtime do
  @moduledoc """
   Runtime domain exposes JavaScript runtime by means of remote evaluation and mirror   objects. Evaluation results are returned as mirror object that expose object type,   string representation and unique identifier that can be used for further object reference.   Original objects are maintained in memory unless they are either explicitly released   or are released along with the other objects in their object group.
  """

  # Represents function call argument. Either remote object id 'objectId', primitive 'value',unserializable primitive value or neither of (for undefined) them should be specified.
  @type call_argument :: String.t()

  # Stack entry for runtime errors and assertions.
  @type call_frame :: String.t()

  # Detailed information about exception (or error) that was thrown during script compilation orexecution.
  @type exception_details :: String.t()

  # Description of an isolated world.
  @type execution_context_description :: String.t()

  # Id of an execution context.
  @type execution_context_id :: integer()

  # Object internal property descriptor. This property isn't normally visible in JavaScript code.
  @type internal_property_descriptor :: String.t()

  # Object property descriptor.
  @type property_descriptor :: String.t()

  # Mirror object referencing original JavaScript object.
  @type remote_object :: String.t()

  # Unique object identifier.
  @type remote_object_id :: String.t()

  # Unique script identifier.
  @type script_id :: String.t()

  # Call frames for assertions or error messages.
  @type stack_trace :: String.t()

  # Number of milliseconds.
  @type time_delta :: integer() | float()

  # Number of milliseconds since epoch.
  @type timestamp :: integer() | float()

  # Primitive value which cannot be JSON-stringified. Includes values '-0', 'NaN', 'Infinity','-Infinity', and bigint literals.
  @type unserializable_value :: String.t()

  @doc """
    Add handler to promise with given promise object id.
  """
  @spec await_promise(promiseObjectId :: remote_object_id(),
          return_by_value: boolean(),
          generate_preview: boolean(),
          async: boolean()
        ) :: %{}
  def await_promise(promise_object_id, opts \\ []) do
    msg = %{
      "promiseObjectId" => promise_object_id
    }

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:return_by_value, :generate_preview], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Calls function with given declaration on the given object. Object group of the result isinherited from the target object.
  """
  @spec call_function_on(functionDeclaration :: String.t(),
          object_id: remote_object_id(),
          arguments: String.t(),
          silent: boolean(),
          return_by_value: boolean(),
          generate_preview: boolean(),
          user_gesture: boolean(),
          await_promise: boolean(),
          execution_context_id: execution_context_id(),
          object_group: String.t(),
          async: boolean()
        ) :: %{}
  def call_function_on(function_declaration, opts \\ []) do
    msg = %{
      "functionDeclaration" => function_declaration
    }

    async = Keyword.get(opts, :async, false)

    params =
      reduce_opts(
        [
          :object_id,
          :arguments,
          :silent,
          :return_by_value,
          :generate_preview,
          :user_gesture,
          :await_promise,
          :execution_context_id,
          :object_group
        ],
        opts
      )

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Compiles expression.
  """
  @spec compile_script(
          expression :: String.t(),
          sourceURL :: String.t(),
          persistScript :: boolean(),
          execution_context_id: execution_context_id(),
          async: boolean()
        ) :: %{}
  def compile_script(expression, source_url, persist_script, opts \\ []) do
    msg = %{
      "expression" => expression,
      "sourceURL" => source_url,
      "persistScript" => persist_script
    }

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:execution_context_id], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Disables reporting of execution contexts creation.
  """
  @spec disable(async: boolean()) :: %{}
  def disable(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Discards collected exceptions and console API calls.
  """
  @spec discard_console_entries(async: boolean()) :: %{}
  def discard_console_entries(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Enables reporting of execution contexts creation by means of 'executionContextCreated' event.When the reporting gets enabled the event will be sent immediately for each existing executioncontext.
  """
  @spec enable(async: boolean()) :: %{}
  def enable(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Evaluates expression on global object.
  """
  @spec evaluate(expression :: String.t(),
          object_group: String.t(),
          include_command_line_api: boolean(),
          silent: boolean(),
          context_id: execution_context_id(),
          return_by_value: boolean(),
          generate_preview: boolean(),
          user_gesture: boolean(),
          await_promise: boolean(),
          throw_on_side_effect: boolean(),
          timeout: time_delta(),
          disable_breaks: boolean(),
          repl_mode: boolean(),
          async: boolean()
        ) :: %{}
  def evaluate(expression, opts \\ []) do
    msg = %{
      "expression" => expression
    }

    async = Keyword.get(opts, :async, false)

    params =
      reduce_opts(
        [
          :object_group,
          :include_command_line_api,
          :silent,
          :context_id,
          :return_by_value,
          :generate_preview,
          :user_gesture,
          :await_promise,
          :throw_on_side_effect,
          :timeout,
          :disable_breaks,
          :repl_mode
        ],
        opts
      )

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Returns properties of a given object. Object group of the result is inherited from the targetobject.
  """
  @spec get_properties(objectId :: remote_object_id(),
          own_properties: boolean(),
          accessor_properties_only: boolean(),
          generate_preview: boolean(),
          async: boolean()
        ) :: %{}
  def get_properties(object_id, opts \\ []) do
    msg = %{
      "objectId" => object_id
    }

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:own_properties, :accessor_properties_only, :generate_preview], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Returns all let, const and class variables from global scope.
  """
  @spec global_lexical_scope_names(execution_context_id: execution_context_id(), async: boolean()) ::
          %{}
  def global_lexical_scope_names(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:execution_context_id], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    
  """
  @spec query_objects(prototypeObjectId :: remote_object_id(),
          object_group: String.t(),
          async: boolean()
        ) :: %{}
  def query_objects(prototype_object_id, opts \\ []) do
    msg = %{
      "prototypeObjectId" => prototype_object_id
    }

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:object_group], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Releases remote object with given id.
  """
  @spec release_object(objectId :: remote_object_id(), async: boolean()) :: %{}
  def release_object(object_id, opts \\ []) do
    msg = %{
      "objectId" => object_id
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Releases all remote objects that belong to a given group.
  """
  @spec release_object_group(objectGroup :: String.t(), async: boolean()) :: %{}
  def release_object_group(object_group, opts \\ []) do
    msg = %{
      "objectGroup" => object_group
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Tells inspected instance to run if it was waiting for debugger to attach.
  """
  @spec run_if_waiting_for_debugger(async: boolean()) :: %{}
  def run_if_waiting_for_debugger(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Runs script with given id in a given context.
  """
  @spec run_script(scriptId :: script_id(),
          execution_context_id: execution_context_id(),
          object_group: String.t(),
          silent: boolean(),
          include_command_line_api: boolean(),
          return_by_value: boolean(),
          generate_preview: boolean(),
          await_promise: boolean(),
          async: boolean()
        ) :: %{}
  def run_script(script_id, opts \\ []) do
    msg = %{
      "scriptId" => script_id
    }

    async = Keyword.get(opts, :async, false)

    params =
      reduce_opts(
        [
          :execution_context_id,
          :object_group,
          :silent,
          :include_command_line_api,
          :return_by_value,
          :generate_preview,
          :await_promise
        ],
        opts
      )

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

  defp reduce_opts(keys, opts) do
    keys
    |> Enum.map(fn key -> {key, Keyword.get(opts, key, :missing)} end)
    |> Enum.reduce(%{}, fn
      {_key, :missing}, acc -> acc
      {key, value}, acc -> Map.put(acc, key, value)
    end)
  end
end
