defmodule Chromex.DevtoolsProtocol.Browser do
  @moduledoc """
    The Browser domain defines methods and events for browser managing.
  """

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
