defmodule Chromex.DevtoolsProtocol.Security do
  @moduledoc """
    Security
  """

  # An internal certificate ID value.
  @type certificate_id :: integer()

  # A description of mixed content (HTTP resources on HTTPS pages), as defined byhttps://www.w3.org/TR/mixed-content/#categories
  @type mixed_content_type :: String.t()

  # The security level of a page or resource.
  @type security_state :: String.t()

  # Details about the security state of the page certificate.
  @type certificate_security_state :: %{
          required(:protocol) => String.t(),
          required(:keyExchange) => String.t(),
          optional(:keyExchangeGroup) => String.t(),
          required(:cipher) => String.t(),
          optional(:mac) => String.t(),
          required(:certificate) => [String.t()],
          required(:subjectName) => String.t(),
          required(:issuer) => String.t(),
          required(:validFrom) => Network.time_since_epoch(),
          required(:validTo) => Network.time_since_epoch(),
          optional(:certificateNetworkError) => String.t(),
          required(:certificateHasWeakSignature) => boolean(),
          required(:certificateHasSha1Signature) => boolean(),
          required(:modernSSL) => boolean(),
          required(:obsoleteSslProtocol) => boolean(),
          required(:obsoleteSslKeyExchange) => boolean(),
          required(:obsoleteSslCipher) => boolean(),
          required(:obsoleteSslSignature) => boolean()
        }

  @type safety_tip_status :: String.t()

  @type safety_tip_info :: %{
          required(:safetyTipStatus) => safety_tip_status(),
          optional(:safeUrl) => String.t()
        }

  # Security state information about the page.
  @type visible_security_state :: %{
          required(:securityState) => security_state(),
          optional(:certificateSecurityState) => certificate_security_state(),
          optional(:safetyTipInfo) => safety_tip_info(),
          required(:securityStateIssueIds) => [String.t()]
        }

  # An explanation of an factor contributing to the security state.
  @type security_state_explanation :: %{
          required(:securityState) => security_state(),
          required(:title) => String.t(),
          required(:summary) => String.t(),
          required(:description) => String.t(),
          required(:mixedContentType) => mixed_content_type(),
          required(:certificate) => [String.t()],
          optional(:recommendations) => [String.t()]
        }

  # Information about insecure content on the page.
  @type insecure_content_status :: %{
          required(:ranMixedContent) => boolean(),
          required(:displayedMixedContent) => boolean(),
          required(:containedMixedForm) => boolean(),
          required(:ranContentWithCertErrors) => boolean(),
          required(:displayedContentWithCertErrors) => boolean(),
          required(:ranInsecureContentStyle) => security_state(),
          required(:displayedInsecureContentStyle) => security_state()
        }

  # The action to take when a certificate error occurs. continue will continue processing therequest and cancel will cancel the request.
  @type certificate_error_action :: String.t()

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
