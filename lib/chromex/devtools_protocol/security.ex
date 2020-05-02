defmodule Chromex.DevtoolsProtocol.Security do
  @moduledoc """
   Security
  """

  # The action to take when a certificate error occurs. continue will continue processing therequest and cancel will cancel the request.
  @type certificate_error_action :: String.t()

  # An internal certificate ID value.
  @type certificate_id :: integer()

  # A description of mixed content (HTTP resources on HTTPS pages), as defined byhttps://www.w3.org/TR/mixed-content/#categories
  @type mixed_content_type :: String.t()

  # The security level of a page or resource.
  @type security_state :: String.t()

  # An explanation of an factor contributing to the security state.
  @type security_state_explanation :: String.t()

  @doc """
    Disables tracking security state changes.
  """
  @spec disable(async: boolean()) :: %{}
  def disable(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Enables tracking security state changes.
  """
  @spec enable(async: boolean()) :: %{}
  def enable(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end
end
