defmodule Chromex.DevtoolsProtocol.Io do
  @moduledoc """
    Input/Output operations for streams produced by DevTools.
  """

  # This is either obtained from another method or specifed as 'blob:&lt;uuid&gt;' where'&lt;uuid&gt' is an UUID of a Blob.
  @type stream_handle :: String.t()

  @doc """
    Close the stream, discard any temporary backing storage.
  """
  @spec close(handle :: stream_handle(), async: boolean()) :: %{}
  def close(handle, opts \\ []) do
    msg = %{
      "handle" => handle
    }

    async = Keyword.get(opts, :async, false)

    Chromex.Browser.send(msg, async: async)
  end

  @doc """
    Read a chunk of the stream
  """
  @spec read(handle :: stream_handle(), offset: integer(), size: integer(), async: boolean()) ::
          %{}
  def read(handle, opts \\ []) do
    msg = %{
      "handle" => handle
    }

    async = Keyword.get(opts, :async, false)

    params = reduce_opts([:offset, :size], opts)

    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send(async: async)
  end

  @doc """
    Return UUID of Blob object specified by a remote object id.
  """
  @spec resolve_blob(objectId :: Runtime.remote_object_id(), async: boolean()) :: %{}
  def resolve_blob(object_id, opts \\ []) do
    msg = %{
      "objectId" => object_id
    }

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
