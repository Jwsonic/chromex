defmodule Chromex.Parser do
  @spec types(list(map())) :: map()
  def types(domains) do
    # dag =
    #   Enum.reduce(domains, %{}, fn domain, acc ->
    #     name = Map.get(domain, "domain")
    #     deps = Map.get(domain, "dependencies", [])
    #     Map.put(acc, name, deps)
    #   end)
    #   |> IO.inspect()

    # Example data
    %{
      "Animation" => %{
        "Animation" => %{
          "id" => {:binary, [], []},
          "name" => {:binary, [], []},
          "pausedState" => {:boolean, [], []},
          "playState" => {:binary, [], []},
          "playbackRate" => {:|, [], [{:float, [], []}, {:integer, [], []}]},
          "startTime" => {:|, [], [{:float, [], []}, {:integer, [], []}]},
          "currentTime" => {:|, [], [{:float, [], []}, {:integer, [], []}]},
          "type" => {:|, [], ["CSSTransition", {:|, [], ["CSSAnimation", "WebAnimation"]}]},
          "source" => "AnimationEffect",
          "cssId" => {:binary, [], []}
        }
      }
    }

    domain_map =
      Enum.reduce(domains, %{}, fn domain, acc ->
        Map.put(acc, domain["domain"], domain)
      end)

    types =
      domain_map
      |> Enum.reduce(%{}, fn {name, domain}, acc ->
        Enum.reduce(domain["types"], acc, fn type, acc ->
          spec = to_spec(type, name, domain_map)

          Map.put(acc, type["id"], spec)
        end)
      end)

    types |> Enum.reject(fn {_key, value} -> is_tuple(value) end) |> IO.inspect()

    # types
  end

  # In th
  defp build_types(_domains, domain_name, types) when is_map_key(types, domain_name) do
    types
  end

  defp build_types(domains, domain, types) do
    # Build out any dependencies this domain has first
    domain["dependencies"]
    |> Enum.map(fn dep -> Enum.find(domains, fn d -> d["domain"] == dep end) end)
    |> Enum.reduce(types, &build_types(domains, &1, types))

    # Real work goes here
  end

  defp to_spec(%{"type" => type}, domain, domains) do
    to_spec(type, domain, domains)
  end

  defp to_spec(%{"type" => "object", "properties" => properties}, domain, domains) do
    specs =
      Enum.map(properties, fn prop ->
        {prop, to_spec(prop, domain, domains)}
      end)

    quote do
      %{
        unquote_splicing(specs)
      }
    end
  end

  defp to_spec(%{"$ref" => ref}, domain, domains) do
    [next_domain, type] =
      case String.split(ref, ".") do
        [type] -> [domain, type]
        [_domain, _type] = path -> path
      end

    ref = get_in(domains, [next_domain, "types", type])

    to_spec(ref, next_domain, domains)
  end

  defp to_spec("string", _domain, _refs) do
    quote do
      binary()
    end
  end

  defp to_spec("boolean", _domain, _refs) do
    quote do
      boolean()
    end
  end

  defp to_spec("number", _domain, _refs) do
    quote do
      float() | integer()
    end
  end

  defp to_spec("integer", _domain, _refs) do
    quote do
      integer()
    end
  end

  defp to_spec("object", _domain, _refs) do
    quote do
      map()
    end
  end

  defp to_spec("array", _domain, _refs) do
    quote do
      list()
    end
  end
end
