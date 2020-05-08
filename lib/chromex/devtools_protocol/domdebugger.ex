defmodule Chromex.DevtoolsProtocol.Domdebugger do
  @moduledoc """
    DOM debugging allows setting breakpoints on particular DOM operations and events.  JavaScript execution will stop on these operations as if there was a regular breakpoint  set.
  """

  # DOM breakpoint type.
  @type dom_breakpoint_type :: String.t()

  # Object event listener.
  @type event_listener :: %{
          required(:type) => String.t(),
          required(:useCapture) => boolean(),
          required(:passive) => boolean(),
          required(:once) => boolean(),
          required(:scriptId) => Runtime.script_id(),
          required(:lineNumber) => integer(),
          required(:columnNumber) => integer(),
          optional(:handler) => Runtime.remote_object(),
          optional(:originalHandler) => Runtime.remote_object(),
          optional(:backendNodeId) => DOM.backend_node_id()
        }

  @doc """
    Returns event listeners of the given object.
  """
  @spec get_event_listeners(objectId :: Runtime.remote_object_id(),
          depth: integer(),
          pierce: boolean(),
          async: boolean()
        ) :: %{}
  def get_event_listeners(object_id, opts \\ []) do
    msg = %{
      "objectId" => object_id,
      "method" => "DOMDebugger.getEventListeners"
    }

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:depth, :pierce], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Removes DOM breakpoint that was set using 'setDOMBreakpoint'.
  """
  @spec remove_dom_breakpoint(nodeId :: DOM.node_id(), type :: dom_breakpoint_type(),
          async: boolean()
        ) :: %{}
  def remove_dom_breakpoint(node_id, type, opts \\ []) do
    msg = %{
      "nodeId" => node_id,
      "type" => type,
      "method" => "DOMDebugger.removeDOMBreakpoint"
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Removes breakpoint on particular DOM event.
  """
  @spec remove_event_listener_breakpoint(eventName :: String.t(),
          target_name: String.t(),
          async: boolean()
        ) :: %{}
  def remove_event_listener_breakpoint(event_name, opts \\ []) do
    msg = %{
      "eventName" => event_name,
      "method" => "DOMDebugger.removeEventListenerBreakpoint"
    }

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:target_name], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Removes breakpoint from XMLHttpRequest.
  """
  @spec remove_xhr_breakpoint(url :: String.t(), async: boolean()) :: %{}
  def remove_xhr_breakpoint(url, opts \\ []) do
    msg = %{
      "url" => url,
      "method" => "DOMDebugger.removeXHRBreakpoint"
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Sets breakpoint on particular operation with DOM.
  """
  @spec set_dom_breakpoint(nodeId :: DOM.node_id(), type :: dom_breakpoint_type(),
          async: boolean()
        ) :: %{}
  def set_dom_breakpoint(node_id, type, opts \\ []) do
    msg = %{
      "nodeId" => node_id,
      "type" => type,
      "method" => "DOMDebugger.setDOMBreakpoint"
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Sets breakpoint on particular DOM event.
  """
  @spec set_event_listener_breakpoint(eventName :: String.t(),
          target_name: String.t(),
          async: boolean()
        ) :: %{}
  def set_event_listener_breakpoint(event_name, opts \\ []) do
    msg = %{
      "eventName" => event_name,
      "method" => "DOMDebugger.setEventListenerBreakpoint"
    }

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:target_name], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Sets breakpoint on XMLHttpRequest.
  """
  @spec set_xhr_breakpoint(url :: String.t(), async: boolean()) :: %{}
  def set_xhr_breakpoint(url, opts \\ []) do
    msg = %{
      "url" => url,
      "method" => "DOMDebugger.setXHRBreakpoint"
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
