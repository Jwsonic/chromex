defmodule Chromex.DevtoolsProtocol.Runtime do
  @moduledoc """
    Runtime domain exposes JavaScript runtime by means of remote evaluation and mirror  objects. Evaluation results are returned as mirror object that expose object type,  string representation and unique identifier that can be used for further object reference.  Original objects are maintained in memory unless they are either explicitly released  or are released along with the other objects in their object group.
  """

  # Unique script identifier.
  @type script_id :: String.t()

  # Unique object identifier.
  @type remote_object_id :: String.t()

  # Primitive value which cannot be JSON-stringified. Includes values '-0', 'NaN', 'Infinity','-Infinity', and bigint literals.
  @type unserializable_value :: String.t()

  # Mirror object referencing original JavaScript object.
  @type remote_object :: %{
          required(:type) => String.t(),
          optional(:subtype) => String.t(),
          optional(:className) => String.t(),
          optional(:value) => any(),
          optional(:unserializableValue) => unserializable_value(),
          optional(:description) => String.t(),
          optional(:objectId) => remote_object_id(),
          optional(:preview) => object_preview(),
          optional(:customPreview) => custom_preview()
        }

  @type custom_preview :: %{
          required(:header) => String.t(),
          optional(:bodyGetterId) => remote_object_id()
        }

  # Object containing abbreviated remote object value.
  @type object_preview :: %{
          required(:type) => String.t(),
          optional(:subtype) => String.t(),
          optional(:description) => String.t(),
          required(:overflow) => boolean(),
          required(:properties) => [property_preview()],
          optional(:entries) => [entry_preview()]
        }

  @type property_preview :: %{
          required(:name) => String.t(),
          required(:type) => String.t(),
          optional(:value) => String.t(),
          optional(:valuePreview) => object_preview(),
          optional(:subtype) => String.t()
        }

  @type entry_preview :: %{
          optional(:key) => object_preview(),
          required(:value) => object_preview()
        }

  # Object property descriptor.
  @type property_descriptor :: %{
          required(:name) => String.t(),
          optional(:value) => remote_object(),
          optional(:writable) => boolean(),
          optional(:get) => remote_object(),
          optional(:set) => remote_object(),
          required(:configurable) => boolean(),
          required(:enumerable) => boolean(),
          optional(:wasThrown) => boolean(),
          optional(:isOwn) => boolean(),
          optional(:symbol) => remote_object()
        }

  # Object internal property descriptor. This property isn't normally visible in JavaScript code.
  @type internal_property_descriptor :: %{
          required(:name) => String.t(),
          optional(:value) => remote_object()
        }

  # Object private field descriptor.
  @type private_property_descriptor :: %{
          required(:name) => String.t(),
          optional(:value) => remote_object(),
          optional(:get) => remote_object(),
          optional(:set) => remote_object()
        }

  # Represents function call argument. Either remote object id 'objectId', primitive 'value',unserializable primitive value or neither of (for undefined) them should be specified.
  @type call_argument :: %{
          optional(:value) => any(),
          optional(:unserializableValue) => unserializable_value(),
          optional(:objectId) => remote_object_id()
        }

  # Id of an execution context.
  @type execution_context_id :: integer()

  # Description of an isolated world.
  @type execution_context_description :: %{
          required(:id) => execution_context_id(),
          required(:origin) => String.t(),
          required(:name) => String.t(),
          optional(:auxData) => map()
        }

  # Detailed information about exception (or error) that was thrown during script compilation orexecution.
  @type exception_details :: %{
          required(:exceptionId) => integer(),
          required(:text) => String.t(),
          required(:lineNumber) => integer(),
          required(:columnNumber) => integer(),
          optional(:scriptId) => script_id(),
          optional(:url) => String.t(),
          optional(:stackTrace) => stack_trace(),
          optional(:exception) => remote_object(),
          optional(:executionContextId) => execution_context_id()
        }

  # Number of milliseconds since epoch.
  @type timestamp :: integer() | float()

  # Number of milliseconds.
  @type time_delta :: integer() | float()

  # Stack entry for runtime errors and assertions.
  @type call_frame :: %{
          required(:functionName) => String.t(),
          required(:scriptId) => script_id(),
          required(:url) => String.t(),
          required(:lineNumber) => integer(),
          required(:columnNumber) => integer()
        }

  # Call frames for assertions or error messages.
  @type stack_trace :: %{
          optional(:description) => String.t(),
          required(:callFrames) => [call_frame()],
          optional(:parent) => stack_trace(),
          optional(:parentId) => stack_trace_id()
        }

  # Unique identifier of current debugger.
  @type unique_debugger_id :: String.t()

  # If 'debuggerId' is set stack trace comes from another debugger and can be resolved there. Thisallows to track cross-debugger calls. See 'Runtime.StackTrace' and 'Debugger.paused' for usages.
  @type stack_trace_id :: %{
          required(:id) => String.t(),
          optional(:debuggerId) => unique_debugger_id()
        }

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
          arguments: [call_argument()],
          silent: boolean(),
          return_by_value: boolean(),
          generate_preview: boolean(),
          user_gesture: boolean(),
          await_promise: boolean(),
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
          :arguments,
          :silent,
          :return_by_value,
          :generate_preview,
          :user_gesture,
          :await_promise,
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
          async: boolean()
        ) :: %{}
  def compile_script(expression, source_url, persist_script, opts \\ []) do
    msg = %{
      "expression" => expression,
      "sourceURL" => source_url,
      "persistScript" => persist_script
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
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
          return_by_value: boolean(),
          generate_preview: boolean(),
          user_gesture: boolean(),
          await_promise: boolean(),
          throw_on_side_effect: boolean(),
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
          :return_by_value,
          :generate_preview,
          :user_gesture,
          :await_promise,
          :throw_on_side_effect,
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
  @spec global_lexical_scope_names(async: boolean()) :: %{}
  def global_lexical_scope_names(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
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
