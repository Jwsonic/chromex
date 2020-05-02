defmodule Chromex.DevtoolsProtocol.Input do
  @moduledoc """
   
  """

  @type mouse_button :: String.t()

  # UTC time in seconds, counted from January 1, 1970.
  @type time_since_epoch :: integer() | float()

  @type touch_point :: String.t()

  @doc """
    Dispatches a key event to the page.
  """
  @spec dispatch_key_event(type :: String.t(),
          modifiers: integer(),
          timestamp: time_since_epoch(),
          text: String.t(),
          unmodified_text: String.t(),
          key_identifier: String.t(),
          code: String.t(),
          key: String.t(),
          windows_virtual_key_code: integer(),
          native_virtual_key_code: integer(),
          auto_repeat: boolean(),
          is_keypad: boolean(),
          is_system_key: boolean(),
          location: integer(),
          async: boolean()
        ) :: %{}
  def dispatch_key_event(type, opts \\ []) do
    msg = %{
      "type" => type
    }

    async = Keyword.get(opts, :async, false)

    params =
      reduce_opts(
        [
          :modifiers,
          :timestamp,
          :text,
          :unmodified_text,
          :key_identifier,
          :code,
          :key,
          :windows_virtual_key_code,
          :native_virtual_key_code,
          :auto_repeat,
          :is_keypad,
          :is_system_key,
          :location
        ],
        opts
      )

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Dispatches a mouse event to the page.
  """
  @spec dispatch_mouse_event(
          type :: String.t(),
          x :: integer() | float(),
          y :: integer() | float(),
          modifiers: integer(),
          timestamp: time_since_epoch(),
          button: mouse_button(),
          buttons: integer(),
          click_count: integer(),
          delta_x: integer() | float(),
          delta_y: integer() | float(),
          pointer_type: String.t(),
          async: boolean()
        ) :: %{}
  def dispatch_mouse_event(type, x, y, opts \\ []) do
    msg = %{
      "type" => type,
      "x" => x,
      "y" => y
    }

    async = Keyword.get(opts, :async, false)

    params =
      reduce_opts(
        [
          :modifiers,
          :timestamp,
          :button,
          :buttons,
          :click_count,
          :delta_x,
          :delta_y,
          :pointer_type
        ],
        opts
      )

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Dispatches a touch event to the page.
  """
  @spec dispatch_touch_event(type :: String.t(), touchPoints :: String.t(),
          modifiers: integer(),
          timestamp: time_since_epoch(),
          async: boolean()
        ) :: %{}
  def dispatch_touch_event(type, touch_points, opts \\ []) do
    msg = %{
      "type" => type,
      "touchPoints" => touch_points
    }

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:modifiers, :timestamp], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Ignores input events (useful while auditing page).
  """
  @spec set_ignore_input_events(ignore :: boolean(), async: boolean()) :: %{}
  def set_ignore_input_events(ignore, opts \\ []) do
    msg = %{
      "ignore" => ignore
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
