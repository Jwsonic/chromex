defmodule Chromex.DevtoolsProtocol.Network do
  @moduledoc """
    Network domain allows tracking network activities of the page. It exposes information  about http, file, data and other requests and responses, their headers, bodies, timing,  etc.
  """

  # The reason why request was blocked.
  @type blocked_reason :: String.t()

  # Information about the cached resource.
  @type cached_resource :: String.t()

  # Whether the request complied with Certificate Transparency policy.
  @type certificate_transparency_compliance :: String.t()

  # The underlying connection technology that the browser is supposedly using.
  @type connection_type :: String.t()

  # Cookie object
  @type cookie :: String.t()

  # Cookie parameter object
  @type cookie_param :: String.t()

  # Represents the cookie's 'SameSite' status:https://tools.ietf.org/html/draft-west-first-party-cookies
  @type cookie_same_site :: String.t()

  # Network level fetch failure reason.
  @type error_reason :: String.t()

  # Request / response headers as keys / values of JSON object.
  @type headers :: String.t()

  # Information about the request initiator.
  @type initiator :: String.t()

  # Unique intercepted request identifier.
  @type interception_id :: String.t()

  # Unique loader identifier.
  @type loader_id :: String.t()

  # Monotonically increasing time in seconds since an arbitrary point in the past.
  @type monotonic_time :: integer() | float()

  # HTTP request data.
  @type request :: String.t()

  # Unique request identifier.
  @type request_id :: String.t()

  # Loading priority of a resource request.
  @type resource_priority :: String.t()

  # Timing information for the request.
  @type resource_timing :: String.t()

  # Resource type as it was perceived by the rendering engine.
  @type resource_type :: String.t()

  # HTTP response data.
  @type response :: String.t()

  # Security details about a request.
  @type security_details :: String.t()

  # Details of a signed certificate timestamp (SCT).
  @type signed_certificate_timestamp :: String.t()

  # UTC time in seconds, counted from January 1, 1970.
  @type time_since_epoch :: integer() | float()

  # WebSocket message data. This represents an entire WebSocket message, not just a fragmented frame as the name suggests.
  @type web_socket_frame :: String.t()

  # WebSocket request data.
  @type web_socket_request :: String.t()

  # WebSocket response data.
  @type web_socket_response :: String.t()

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
          connection_type: connection_type(),
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

    params = reduce_opts([:connection_type], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
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
  @spec get_cookies(urls: String.t(), async: boolean()) :: %{}
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
          same_site: cookie_same_site(),
          expires: time_since_epoch(),
          async: boolean()
        ) :: %{}
  def set_cookie(name, value, opts \\ []) do
    msg = %{
      "name" => name,
      "value" => value
    }

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:url, :domain, :path, :secure, :http_only, :same_site, :expires], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Sets given cookies.
  """
  @spec set_cookies(cookies :: String.t(), async: boolean()) :: %{}
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
