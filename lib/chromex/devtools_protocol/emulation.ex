defmodule Chromex.DevtoolsProtocol.Emulation do
  @moduledoc """
    This domain emulates different environments for the page.
  """

  # Screen orientation.
  @type screen_orientation :: %{required(:type) => String.t(), required(:angle) => integer()}

  @type media_feature :: %{required(:name) => String.t(), required(:value) => String.t()}

  # advance: If the scheduler runs out of immediate work, the virtual time base may fast forward toallow the next delayed task (if any) to run; pause: The virtual time base may not advance;pauseIfNetworkFetchesPending: The virtual time base may not advance if there are any pendingresource fetches.
  @type virtual_time_policy :: String.t()

  @doc """
    Tells whether emulation is supported.
  """
  @spec can_emulate(async: boolean()) :: %{}
  def can_emulate(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Clears the overriden device metrics.
  """
  @spec clear_device_metrics_override(async: boolean()) :: %{}
  def clear_device_metrics_override(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Clears the overriden Geolocation Position and Error.
  """
  @spec clear_geolocation_override(async: boolean()) :: %{}
  def clear_geolocation_override(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Sets or clears an override of the default background color of the frame. This override is usedif the content does not specify one.
  """
  @spec set_default_background_color_override(async: boolean()) :: %{}
  def set_default_background_color_override(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Overrides the values of device screen dimensions (window.screen.width, window.screen.height,window.innerWidth, window.innerHeight, and "device-width"/"device-height"-related CSS mediaquery results).
  """
  @spec set_device_metrics_override(
          width :: integer(),
          height :: integer(),
          deviceScaleFactor :: integer() | float(),
          mobile :: boolean(),
          scale: integer() | float(),
          screen_width: integer(),
          screen_height: integer(),
          position_x: integer(),
          position_y: integer(),
          dont_set_visible_size: boolean(),
          async: boolean()
        ) :: %{}
  def set_device_metrics_override(width, height, device_scale_factor, mobile, opts \\ []) do
    msg = %{
      "width" => width,
      "height" => height,
      "deviceScaleFactor" => device_scale_factor,
      "mobile" => mobile
    }

    async = Keyword.get(opts, :async, false)

    params =
      reduce_opts(
        [:scale, :screen_width, :screen_height, :position_x, :position_y, :dont_set_visible_size],
        opts
      )

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Emulates the given media type or media feature for CSS media queries.
  """
  @spec set_emulated_media(media: String.t(), features: [media_feature()], async: boolean()) ::
          %{}
  def set_emulated_media(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:media, :features], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Overrides the Geolocation Position or Error. Omitting any of the parameters emulates positionunavailable.
  """
  @spec set_geolocation_override(
          latitude: integer() | float(),
          longitude: integer() | float(),
          accuracy: integer() | float(),
          async: boolean()
        ) :: %{}
  def set_geolocation_override(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:latitude, :longitude, :accuracy], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Switches script execution in the page.
  """
  @spec set_script_execution_disabled(value :: boolean(), async: boolean()) :: %{}
  def set_script_execution_disabled(value, opts \\ []) do
    msg = %{
      "value" => value
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Enables touch on platforms which do not support them.
  """
  @spec set_touch_emulation_enabled(enabled :: boolean(),
          max_touch_points: integer(),
          async: boolean()
        ) :: %{}
  def set_touch_emulation_enabled(enabled, opts \\ []) do
    msg = %{
      "enabled" => enabled
    }

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:max_touch_points], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Allows overriding user agent with the given string.
  """
  @spec set_user_agent_override(userAgent :: String.t(),
          accept_language: String.t(),
          platform: String.t(),
          async: boolean()
        ) :: %{}
  def set_user_agent_override(user_agent, opts \\ []) do
    msg = %{
      "userAgent" => user_agent
    }

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:accept_language, :platform], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
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
