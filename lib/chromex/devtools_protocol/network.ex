defmodule Chromex.DevtoolsProtocol.Network do
  @moduledoc """
    Network domain allows tracking network activities of the page. It exposes information  about http, file, data and other requests and responses, their headers, bodies, timing,  etc.
  """

  # Resource type as it was perceived by the rendering engine.
  @type resource_type :: String.t()

  # Unique loader identifier.
  @type loader_id :: String.t()

  # Unique request identifier.
  @type request_id :: String.t()

  # Unique intercepted request identifier.
  @type interception_id :: String.t()

  # Network level fetch failure reason.
  @type error_reason :: String.t()

  # UTC time in seconds, counted from January 1, 1970.
  @type time_since_epoch :: integer() | float()

  # Monotonically increasing time in seconds since an arbitrary point in the past.
  @type monotonic_time :: integer() | float()

  # Request / response headers as keys / values of JSON object.
  @type headers :: map()

  # The underlying connection technology that the browser is supposedly using.
  @type connection_type :: String.t()

  # Represents the cookie's 'SameSite' status:https://tools.ietf.org/html/draft-west-first-party-cookies
  @type cookie_same_site :: String.t()

  # Represents the cookie's 'Priority' status:https://tools.ietf.org/html/draft-west-cookie-priority-00
  @type cookie_priority :: String.t()

  # Timing information for the request.
  @type resource_timing :: %{
          required(:requestTime) => integer() | float(),
          required(:proxyStart) => integer() | float(),
          required(:proxyEnd) => integer() | float(),
          required(:dnsStart) => integer() | float(),
          required(:dnsEnd) => integer() | float(),
          required(:connectStart) => integer() | float(),
          required(:connectEnd) => integer() | float(),
          required(:sslStart) => integer() | float(),
          required(:sslEnd) => integer() | float(),
          required(:workerStart) => integer() | float(),
          required(:workerReady) => integer() | float(),
          required(:sendStart) => integer() | float(),
          required(:sendEnd) => integer() | float(),
          required(:pushStart) => integer() | float(),
          required(:pushEnd) => integer() | float(),
          required(:receiveHeadersEnd) => integer() | float()
        }

  # Loading priority of a resource request.
  @type resource_priority :: String.t()

  # HTTP request data.
  @type request :: %{
          required(:url) => String.t(),
          optional(:urlFragment) => String.t(),
          required(:method) => String.t(),
          required(:headers) => headers(),
          optional(:postData) => String.t(),
          optional(:hasPostData) => boolean(),
          optional(:mixedContentType) => Security.mixed_content_type(),
          required(:initialPriority) => resource_priority(),
          required(:referrerPolicy) => String.t(),
          optional(:isLinkPreload) => boolean()
        }

  # Details of a signed certificate timestamp (SCT).
  @type signed_certificate_timestamp :: %{
          required(:status) => String.t(),
          required(:origin) => String.t(),
          required(:logDescription) => String.t(),
          required(:logId) => String.t(),
          required(:timestamp) => time_since_epoch(),
          required(:hashAlgorithm) => String.t(),
          required(:signatureAlgorithm) => String.t(),
          required(:signatureData) => String.t()
        }

  # Security details about a request.
  @type security_details :: %{
          required(:protocol) => String.t(),
          required(:keyExchange) => String.t(),
          optional(:keyExchangeGroup) => String.t(),
          required(:cipher) => String.t(),
          optional(:mac) => String.t(),
          required(:certificateId) => Security.certificate_id(),
          required(:subjectName) => String.t(),
          required(:sanList) => [String.t()],
          required(:issuer) => String.t(),
          required(:validFrom) => time_since_epoch(),
          required(:validTo) => time_since_epoch(),
          required(:signedCertificateTimestampList) => [signed_certificate_timestamp()],
          required(:certificateTransparencyCompliance) => certificate_transparency_compliance()
        }

  # Whether the request complied with Certificate Transparency policy.
  @type certificate_transparency_compliance :: String.t()

  # The reason why request was blocked.
  @type blocked_reason :: String.t()

  # HTTP response data.
  @type response :: %{
          required(:url) => String.t(),
          required(:status) => integer(),
          required(:statusText) => String.t(),
          required(:headers) => headers(),
          optional(:headersText) => String.t(),
          required(:mimeType) => String.t(),
          optional(:requestHeaders) => headers(),
          optional(:requestHeadersText) => String.t(),
          required(:connectionReused) => boolean(),
          required(:connectionId) => integer() | float(),
          optional(:remoteIPAddress) => String.t(),
          optional(:remotePort) => integer(),
          optional(:fromDiskCache) => boolean(),
          optional(:fromServiceWorker) => boolean(),
          optional(:fromPrefetchCache) => boolean(),
          required(:encodedDataLength) => integer() | float(),
          optional(:timing) => resource_timing(),
          optional(:protocol) => String.t(),
          required(:securityState) => Security.security_state(),
          optional(:securityDetails) => security_details()
        }

  # WebSocket request data.
  @type web_socket_request :: %{required(:headers) => headers()}

  # WebSocket response data.
  @type web_socket_response :: %{
          required(:status) => integer(),
          required(:statusText) => String.t(),
          required(:headers) => headers(),
          optional(:headersText) => String.t(),
          optional(:requestHeaders) => headers(),
          optional(:requestHeadersText) => String.t()
        }

  # WebSocket message data. This represents an entire WebSocket message, not just a fragmented frame as the name suggests.
  @type web_socket_frame :: %{
          required(:opcode) => integer() | float(),
          required(:mask) => boolean(),
          required(:payloadData) => String.t()
        }

  # Information about the cached resource.
  @type cached_resource :: %{
          required(:url) => String.t(),
          required(:type) => resource_type(),
          optional(:response) => response(),
          required(:bodySize) => integer() | float()
        }

  # Information about the request initiator.
  @type initiator :: %{
          required(:type) => String.t(),
          optional(:stack) => Runtime.stack_trace(),
          optional(:url) => String.t(),
          optional(:lineNumber) => integer() | float()
        }

  # Cookie object
  @type cookie :: %{
          required(:name) => String.t(),
          required(:value) => String.t(),
          required(:domain) => String.t(),
          required(:path) => String.t(),
          required(:expires) => integer() | float(),
          required(:size) => integer(),
          required(:httpOnly) => boolean(),
          required(:secure) => boolean(),
          required(:session) => boolean(),
          optional(:sameSite) => cookie_same_site(),
          required(:priority) => cookie_priority()
        }

  # Types of reasons why a cookie may not be stored from a response.
  @type set_cookie_blocked_reason :: String.t()

  # Types of reasons why a cookie may not be sent with a request.
  @type cookie_blocked_reason :: String.t()

  # A cookie which was not stored from a response with the corresponding reason.
  @type blocked_set_cookie_with_reason :: %{
          required(:blockedReasons) => [set_cookie_blocked_reason()],
          required(:cookieLine) => String.t(),
          optional(:cookie) => cookie()
        }

  # A cookie with was not sent with a request with the corresponding reason.
  @type blocked_cookie_with_reason :: %{
          required(:blockedReasons) => [cookie_blocked_reason()],
          required(:cookie) => cookie()
        }

  # Cookie parameter object
  @type cookie_param :: %{
          required(:name) => String.t(),
          required(:value) => String.t(),
          optional(:url) => String.t(),
          optional(:domain) => String.t(),
          optional(:path) => String.t(),
          optional(:secure) => boolean(),
          optional(:httpOnly) => boolean(),
          optional(:sameSite) => cookie_same_site(),
          optional(:expires) => time_since_epoch(),
          optional(:priority) => cookie_priority()
        }

  # Authorization challenge for HTTP status code 401 or 407.
  @type auth_challenge :: %{
          optional(:source) => String.t(),
          required(:origin) => String.t(),
          required(:scheme) => String.t(),
          required(:realm) => String.t()
        }

  # Response to an AuthChallenge.
  @type auth_challenge_response :: %{
          required(:response) => String.t(),
          optional(:username) => String.t(),
          optional(:password) => String.t()
        }

  # Stages of the interception to begin intercepting. Request will intercept before the request issent. Response will intercept after the response is received.
  @type interception_stage :: String.t()

  # Request pattern for interception.
  @type request_pattern :: %{
          optional(:urlPattern) => String.t(),
          optional(:resourceType) => resource_type(),
          optional(:interceptionStage) => interception_stage()
        }

  # Information about a signed exchange signature.https://wicg.github.io/webpackage/draft-yasskin-httpbis-origin-signed-exchanges-impl.html#rfc.section.3.1
  @type signed_exchange_signature :: %{
          required(:label) => String.t(),
          required(:signature) => String.t(),
          required(:integrity) => String.t(),
          optional(:certUrl) => String.t(),
          optional(:certSha256) => String.t(),
          required(:validityUrl) => String.t(),
          required(:date) => integer(),
          required(:expires) => integer(),
          optional(:certificates) => [String.t()]
        }

  # Information about a signed exchange header.https://wicg.github.io/webpackage/draft-yasskin-httpbis-origin-signed-exchanges-impl.html#cbor-representation
  @type signed_exchange_header :: %{
          required(:requestUrl) => String.t(),
          required(:responseCode) => integer(),
          required(:responseHeaders) => headers(),
          required(:signatures) => [signed_exchange_signature()],
          required(:headerIntegrity) => String.t()
        }

  # Field type for a signed exchange related error.
  @type signed_exchange_error_field :: String.t()

  # Information about a signed exchange response.
  @type signed_exchange_error :: %{
          required(:message) => String.t(),
          optional(:signatureIndex) => integer(),
          optional(:errorField) => signed_exchange_error_field()
        }

  # Information about a signed exchange response.
  @type signed_exchange_info :: %{
          required(:outerResponse) => response(),
          optional(:header) => signed_exchange_header(),
          optional(:securityDetails) => security_details(),
          optional(:errors) => [signed_exchange_error()]
        }

  @doc """
    Clears browser cache.
  """
  @spec clear_browser_cache(async: boolean()) :: %{}
  def clear_browser_cache(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Clears browser cookies.
  """
  @spec clear_browser_cookies(async: boolean()) :: %{}
  def clear_browser_cookies(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Deletes browser cookies with matching name and url or domain/path pair.
  """
  @spec delete_cookies(name :: String.t(),
          url: String.t(),
          domain: String.t(),
          path: String.t(),
          async: boolean()
        ) :: %{}
  def delete_cookies(name, opts \\ []) do
    msg = %{
      "name" => name
    }

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:url, :domain, :path], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Disables network tracking, prevents network events from being sent to the client.
  """
  @spec disable(async: boolean()) :: %{}
  def disable(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Activates emulation of network conditions.
  """
  @spec emulate_network_conditions(
          offline :: boolean(),
          latency :: integer() | float(),
          downloadThroughput :: integer() | float(),
          uploadThroughput :: integer() | float(),
          async: boolean()
        ) :: %{}
  def emulate_network_conditions(
        offline,
        latency,
        download_throughput,
        upload_throughput,
        opts \\ []
      ) do
    msg = %{
      "offline" => offline,
      "latency" => latency,
      "downloadThroughput" => download_throughput,
      "uploadThroughput" => upload_throughput
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Enables network tracking, network events will now be delivered to the client.
  """
  @spec enable(
          max_total_buffer_size: integer(),
          max_resource_buffer_size: integer(),
          max_post_data_size: integer(),
          async: boolean()
        ) :: %{}
  def enable(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    params =
      reduce_opts([:max_total_buffer_size, :max_resource_buffer_size, :max_post_data_size], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Returns all browser cookies. Depending on the backend support, will return detailed cookieinformation in the 'cookies' field.
  """
  @spec get_all_cookies(async: boolean()) :: %{}
  def get_all_cookies(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Returns all browser cookies for the current URL. Depending on the backend support, will returndetailed cookie information in the 'cookies' field.
  """
  @spec get_cookies(urls: [String.t()], async: boolean()) :: %{}
  def get_cookies(opts \\ []) do
    msg = %{}

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:urls], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Returns post data sent with the request. Returns an error when no data was sent with the request.
  """
  @spec get_request_post_data(requestId :: request_id(), async: boolean()) :: %{}
  def get_request_post_data(request_id, opts \\ []) do
    msg = %{
      "requestId" => request_id
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Returns content served for the given request.
  """
  @spec get_response_body(requestId :: request_id(), async: boolean()) :: %{}
  def get_response_body(request_id, opts \\ []) do
    msg = %{
      "requestId" => request_id
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Toggles ignoring cache for each request. If 'true', cache will not be used.
  """
  @spec set_cache_disabled(cacheDisabled :: boolean(), async: boolean()) :: %{}
  def set_cache_disabled(cache_disabled, opts \\ []) do
    msg = %{
      "cacheDisabled" => cache_disabled
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Sets a cookie with the given cookie data; may overwrite equivalent cookies if they exist.
  """
  @spec set_cookie(name :: String.t(), value :: String.t(),
          url: String.t(),
          domain: String.t(),
          path: String.t(),
          secure: boolean(),
          http_only: boolean(),
          async: boolean()
        ) :: %{}
  def set_cookie(name, value, opts \\ []) do
    msg = %{
      "name" => name,
      "value" => value
    }

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:url, :domain, :path, :secure, :http_only], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Sets given cookies.
  """
  @spec set_cookies(cookies :: [cookie_param()], async: boolean()) :: %{}
  def set_cookies(cookies, opts \\ []) do
    msg = %{
      "cookies" => cookies
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Specifies whether to always send extra HTTP headers with the requests from this page.
  """
  @spec set_extra_http_headers(headers :: headers(), async: boolean()) :: %{}
  def set_extra_http_headers(headers, opts \\ []) do
    msg = %{
      "headers" => headers
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
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
