defmodule Chromex.DevtoolsProtocol.Dom do
  @moduledoc """
   This domain exposes DOM read/write operations. Each DOM Node is represented with   its mirror object that has an `id`. This `id` can be used to get additional information   on the Node, resolve it into the JavaScript object wrapper, etc. It is important   that client receives DOM events only for the nodes that are known to the client.   Backend keeps track of the nodes that were sent to the client and never sends the   same node twice. It is client's responsibility to collect information about the nodes   that were sent to the client.<p>Note that `iframe` owner elements will return corresponding   document elements as their child nodes.</p>
  """

  # Backend node with a friendly name.
  @type backend_node :: String.t()

  # Unique DOM node identifier used to reference a node that may not have been pushed to thefront-end.
  @type backend_node_id :: integer()

  # Box model.
  @type box_model :: String.t()

  # DOM interaction is implemented in terms of mirror objects that represent the actual DOM nodes.DOMNode is a base node mirror type.
  @type node_ :: String.t()

  # Unique DOM node identifier.
  @type node_id :: integer()

  # Pseudo element type.
  @type pseudo_type :: String.t()

  # An array of quad vertices, x immediately followed by y for each point, points clock-wise.
  @type quad :: String.t()

  # A structure holding an RGBA color.
  @type rgba :: String.t()

  # Rectangle.
  @type rect :: String.t()

  # Shadow root type.
  @type shadow_root_type :: String.t()

  # CSS Shape Outside details.
  @type shape_outside_info :: String.t()

  @doc """
    Describes node given its id, does not require domain to be enabled. Does not start tracking anyobjects, can be used for automation.
  """
  @spec describe_node(
          node_id: node_id(),
          backend_node_id: backend_node_id(),
          depth: integer(),
          pierce: boolean(),
          async: boolean()
        ) :: %{}
  def describe_node(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:node_id, :backend_node_id, :depth, :pierce], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Disables DOM agent for the given page.
  """
  @spec disable(async: boolean()) :: %{}
  def disable(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Enables DOM agent for the given page.
  """
  @spec enable(async: boolean()) :: %{}
  def enable(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Focuses the given element.
  """
  @spec focus(node_id: node_id(), backend_node_id: backend_node_id(), async: boolean()) :: %{}
  def focus(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:node_id, :backend_node_id], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Returns attributes for the specified node.
  """
  @spec get_attributes(nodeId :: node_id(), async: boolean()) :: %{}
  def get_attributes(node_id, opts \\ []) do
    msg = %{
      "nodeId" => node_id
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Returns boxes for the given node.
  """
  @spec get_box_model(node_id: node_id(), backend_node_id: backend_node_id(), async: boolean()) ::
          %{}
  def get_box_model(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:node_id, :backend_node_id], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Returns the root DOM node (and optionally the subtree) to the caller.
  """
  @spec get_document(depth: integer(), pierce: boolean(), async: boolean()) :: %{}
  def get_document(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:depth, :pierce], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Returns the root DOM node (and optionally the subtree) to the caller.
  """
  @spec get_flattened_document(depth: integer(), pierce: boolean(), async: boolean()) :: %{}
  def get_flattened_document(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:depth, :pierce], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Returns node id at given location. Depending on whether DOM domain is enabled, nodeId iseither returned or not.
  """
  @spec get_node_for_location(x :: integer(), y :: integer(),
          include_user_agent_shadow_dom: boolean(),
          ignore_pointer_events_none: boolean(),
          async: boolean()
        ) :: %{}
  def get_node_for_location(x, y, opts \\ []) do
    msg = %{
      "x" => x,
      "y" => y
    }

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:include_user_agent_shadow_dom, :ignore_pointer_events_none], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Returns node's HTML markup.
  """
  @spec get_outer_html(node_id: node_id(), backend_node_id: backend_node_id(), async: boolean()) ::
          %{}
  def get_outer_html(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:node_id, :backend_node_id], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Hides any highlight.
  """
  @spec hide_highlight(async: boolean()) :: %{}
  def hide_highlight(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Highlights DOM node.
  """
  @spec highlight_node(async: boolean()) :: %{}
  def highlight_node(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Highlights given rectangle.
  """
  @spec highlight_rect(async: boolean()) :: %{}
  def highlight_rect(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Moves node into the new container, places it before the given anchor.
  """
  @spec move_to(nodeId :: node_id(), targetNodeId :: node_id(),
          insert_before_node_id: node_id(),
          async: boolean()
        ) :: %{}
  def move_to(node_id, target_node_id, opts \\ []) do
    msg = %{
      "nodeId" => node_id,
      "targetNodeId" => target_node_id
    }

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:insert_before_node_id], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Executes 'querySelector' on a given node.
  """
  @spec query_selector(nodeId :: node_id(), selector :: String.t(), async: boolean()) :: %{}
  def query_selector(node_id, selector, opts \\ []) do
    msg = %{
      "nodeId" => node_id,
      "selector" => selector
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Executes 'querySelectorAll' on a given node.
  """
  @spec query_selector_all(nodeId :: node_id(), selector :: String.t(), async: boolean()) :: %{}
  def query_selector_all(node_id, selector, opts \\ []) do
    msg = %{
      "nodeId" => node_id,
      "selector" => selector
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Removes attribute with given name from an element with given id.
  """
  @spec remove_attribute(nodeId :: node_id(), name :: String.t(), async: boolean()) :: %{}
  def remove_attribute(node_id, name, opts \\ []) do
    msg = %{
      "nodeId" => node_id,
      "name" => name
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Removes node with given id.
  """
  @spec remove_node(nodeId :: node_id(), async: boolean()) :: %{}
  def remove_node(node_id, opts \\ []) do
    msg = %{
      "nodeId" => node_id
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Requests that children of the node with given id are returned to the caller in form of'setChildNodes' events where not only immediate children are retrieved, but all children down tothe specified depth.
  """
  @spec request_child_nodes(nodeId :: node_id(),
          depth: integer(),
          pierce: boolean(),
          async: boolean()
        ) :: %{}
  def request_child_nodes(node_id, opts \\ []) do
    msg = %{
      "nodeId" => node_id
    }

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:depth, :pierce], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Requests that the node is sent to the caller given the JavaScript node object reference. Allnodes that form the path from the node to the root are also sent to the client as a series of'setChildNodes' notifications.
  """
  @spec request_node(objectId :: Runtime.remote_object_id(), async: boolean()) :: %{}
  def request_node(object_id, opts \\ []) do
    msg = %{
      "objectId" => object_id
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Resolves the JavaScript node object for a given NodeId or BackendNodeId.
  """
  @spec resolve_node(node_id: node_id(), object_group: String.t(), async: boolean()) :: %{}
  def resolve_node(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:node_id, :object_group], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Sets attribute for an element with given id.
  """
  @spec set_attribute_value(nodeId :: node_id(), name :: String.t(), value :: String.t(),
          async: boolean()
        ) :: %{}
  def set_attribute_value(node_id, name, value, opts \\ []) do
    msg = %{
      "nodeId" => node_id,
      "name" => name,
      "value" => value
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Sets attributes on element with given id. This method is useful when user edits some existingattribute value and types in several attribute name/value pairs.
  """
  @spec set_attributes_as_text(nodeId :: node_id(), text :: String.t(),
          name: String.t(),
          async: boolean()
        ) :: %{}
  def set_attributes_as_text(node_id, text, opts \\ []) do
    msg = %{
      "nodeId" => node_id,
      "text" => text
    }

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:name], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Sets files for the given file input element.
  """
  @spec set_file_input_files(files :: String.t(),
          node_id: node_id(),
          backend_node_id: backend_node_id(),
          async: boolean()
        ) :: %{}
  def set_file_input_files(files, opts \\ []) do
    msg = %{
      "files" => files
    }

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:node_id, :backend_node_id], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Sets node name for a node with given id.
  """
  @spec set_node_name(nodeId :: node_id(), name :: String.t(), async: boolean()) :: %{}
  def set_node_name(node_id, name, opts \\ []) do
    msg = %{
      "nodeId" => node_id,
      "name" => name
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Sets node value for a node with given id.
  """
  @spec set_node_value(nodeId :: node_id(), value :: String.t(), async: boolean()) :: %{}
  def set_node_value(node_id, value, opts \\ []) do
    msg = %{
      "nodeId" => node_id,
      "value" => value
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Sets node HTML markup, returns new node id.
  """
  @spec set_outer_html(nodeId :: node_id(), outerHTML :: String.t(), async: boolean()) :: %{}
  def set_outer_html(node_id, outer_html, opts \\ []) do
    msg = %{
      "nodeId" => node_id,
      "outerHTML" => outer_html
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
