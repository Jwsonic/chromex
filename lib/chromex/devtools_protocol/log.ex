defmodule Chromex.DevtoolsProtocol.Log do
  @moduledoc """
    Provides access to log entries.
  """

  # Log entry.
  @type log_entry :: %{
          required(:source) => String.t(),
          required(:level) => String.t(),
          required(:text) => String.t(),
          required(:timestamp) => Runtime.timestamp(),
          optional(:url) => String.t(),
          optional(:lineNumber) => integer(),
          optional(:stackTrace) => Runtime.stack_trace(),
          optional(:networkRequestId) => Network.request_id(),
          optional(:workerId) => String.t(),
          optional(:args) => [Runtime.remote_object()]
        }

  # Violation configuration setting.
  @type violation_setting :: %{
          required(:name) => String.t(),
          required(:threshold) => integer() | float()
        }

  @doc """
    Clears the log.
  """
  @spec clear(async: boolean()) :: %{}
  def clear(opts \\ []) do
    msg = %{
      "method" => "Log.clear"
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Disables log domain, prevents further log entries from being reported to the client.
  """
  @spec disable(async: boolean()) :: %{}
  def disable(opts \\ []) do
    msg = %{
      "method" => "Log.disable"
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Enables log domain, sends the entries collected so far to the client by means of the'entryAdded' notification.
  """
  @spec enable(async: boolean()) :: %{}
  def enable(opts \\ []) do
    msg = %{
      "method" => "Log.enable"
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    start violation reporting.
  """
  @spec start_violations_report(config :: [violation_setting()], async: boolean()) :: %{}
  def start_violations_report(config, opts \\ []) do
    msg = %{
      "config" => config,
      "method" => "Log.startViolationsReport"
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Stop violation reporting.
  """
  @spec stop_violations_report(async: boolean()) :: %{}
  def stop_violations_report(opts \\ []) do
    msg = %{
      "method" => "Log.stopViolationsReport"
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end
end
