defmodule Chromex.DevtoolsProtocol.Performance do
  @moduledoc """
    
  """

  # Run-time execution metric.
  @type metric :: String.t()

  @doc """
    Disable collecting and reporting metrics.
  """
  @spec disable(async: boolean()) :: %{}
  def disable(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Enable collecting and reporting metrics.
  """
  @spec enable(time_domain: String.t(), async: boolean()) :: %{}
  def enable(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:time_domain], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Retrieve current values of run-time metrics.
  """
  @spec get_metrics(async: boolean()) :: %{}
  def get_metrics(opts \\ []) do
    msg = %{}

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
