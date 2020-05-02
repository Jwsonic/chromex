defmodule Chromex.DevtoolsProtocol.Target do
  @moduledoc """
   Supports additional targets discovery and allows to attach to them.
  """

  # Unique identifier of attached debugging session.
  @type session_id :: String.t()

  @type target_id :: String.t()

  @type target_info :: String.t()

  @doc """
    Activates (focuses) the target.
  """
  @spec activate_target(targetId :: target_id(), async: boolean()) :: %{}
  def activate_target(target_id, opts \\ []) do
    msg = %{
      "targetId" => target_id
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Attaches to the target with given id.
  """
  @spec attach_to_target(targetId :: target_id(), flatten: boolean(), async: boolean()) :: %{}
  def attach_to_target(target_id, opts \\ []) do
    msg = %{
      "targetId" => target_id
    }

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:flatten], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Closes the target. If the target is a page that gets closed too.
  """
  @spec close_target(targetId :: target_id(), async: boolean()) :: %{}
  def close_target(target_id, opts \\ []) do
    msg = %{
      "targetId" => target_id
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Creates a new page.
  """
  @spec create_target(url :: String.t(),
          width: integer(),
          height: integer(),
          enable_begin_frame_control: boolean(),
          new_window: boolean(),
          background: boolean(),
          async: boolean()
        ) :: %{}
  def create_target(url, opts \\ []) do
    msg = %{
      "url" => url
    }

    async = Keyword.get(opts, :async, false)

    params =
      reduce_opts([:width, :height, :enable_begin_frame_control, :new_window, :background], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Detaches session with given id.
  """
  @spec detach_from_target(session_id: session_id(), target_id: target_id(), async: boolean()) ::
          %{}
  def detach_from_target(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:session_id, :target_id], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Retrieves a list of available targets.
  """
  @spec get_targets(async: boolean()) :: %{}
  def get_targets(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Controls whether to discover available targets and notify via'targetCreated/targetInfoChanged/targetDestroyed' events.
  """
  @spec set_discover_targets(discover :: boolean(), async: boolean()) :: %{}
  def set_discover_targets(discover, opts \\ []) do
    msg = %{
      "discover" => discover
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
