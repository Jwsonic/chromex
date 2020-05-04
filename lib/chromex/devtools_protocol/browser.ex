defmodule Chromex.DevtoolsProtocol.Browser do
  @moduledoc """
    The Browser domain defines methods and events for browser managing.
  """

  @type browser_context_id :: String.t()

  @type window_id :: integer()

  # The state of the browser window.
  @type window_state :: String.t()

  # Browser window bounds information
  @type bounds :: %{
          optional(:left) => integer(),
          optional(:top) => integer(),
          optional(:width) => integer(),
          optional(:height) => integer(),
          optional(:windowState) => window_state()
        }

  @type permission_type :: String.t()

  @type permission_setting :: String.t()

  # Definition of PermissionDescriptor defined in the Permissions API:https://w3c.github.io/permissions/#dictdef-permissiondescriptor.
  @type permission_descriptor :: %{
          required(:name) => String.t(),
          optional(:sysex) => boolean(),
          optional(:userVisibleOnly) => boolean(),
          optional(:type) => String.t(),
          optional(:allowWithoutSanitization) => boolean()
        }

  # Chrome histogram bucket.
  @type bucket :: %{
          required(:low) => integer(),
          required(:high) => integer(),
          required(:count) => integer()
        }

  # Chrome histogram.
  @type histogram :: %{
          required(:name) => String.t(),
          required(:sum) => integer(),
          required(:count) => integer(),
          required(:buckets) => [bucket()]
        }

  @doc """
    Close browser gracefully.
  """
  @spec close(async: boolean()) :: %{}
  def close(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Returns version information.
  """
  @spec get_version(async: boolean()) :: %{}
  def get_version(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end
end
