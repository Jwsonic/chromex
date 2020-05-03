defmodule Chromex.DevtoolsProtocol.Log do
  @moduledoc """
    Provides access to log entries.
  """

  # Log entry.
  @type log_entry :: String.t()

  # Violation configuration setting.
  @type violation_setting :: String.t()

  @doc """
    Clears the log.
  """
  @spec clear(async: boolean()) :: %{}
  def clear(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Disables log domain, prevents further log entries from being reported to the client.
  """
  @spec disable(async: boolean()) :: %{}
  def disable(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Enables log domain, sends the entries collected so far to the client by means of the'entryAdded' notification.
  """
  @spec enable(async: boolean()) :: %{}
  def enable(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    start violation reporting.
  """
  @spec start_violations_report(config :: String.t(), async: boolean()) :: %{}
  def start_violations_report(config, opts \\ []) do
    msg = %{
      "config" => config
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Stop violation reporting.
  """
  @spec stop_violations_report(async: boolean()) :: %{}
  def stop_violations_report(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end
end
