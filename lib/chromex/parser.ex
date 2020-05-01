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

    domain_map = Enum.group_by(domains, &Map.get(&1, "domain")) |> IO.inspect()

    types =
      domains
      |> Enum.flat_map(&Map.get(&1, "types", []))
      |> Enum.reject(&Map.get(&1, "experimental", false))
      |> Enum.reduce(%{}, fn %{"id" => id} = type, acc ->
        spec = to_spec(%{"type" => type}, domain_map)

        # get ref here
        Map.put(acc, id, spec)
      end)

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

  defp to_spec(%{"type" => type}, refs) do
    to_spec(type, refs)
  end

  defp to_spec(%{"$ref" => ref}, domains) do
    [domain, type] =
      case String.split(ref, ".") do
        [type] -> ["domain", type]
        [_domain, _type] = path -> path
      end

    ref = get_in(domains, [domain, "types", type])

    to_spec(ref, domains)
  end

  defp to_spec("string", _refs) do
    quote do
      binary()
    end
  end

  defp to_spec("boolean", _refs) do
    quote do
      boolean()
    end
  end

  defp to_spec("number", _refs) do
    quote do
      float() | integer()
    end
  end

  defp to_spec("integer", _refs) do
    quote do
      integer()
    end
  end

  defp to_spec("object", _refs) do
    quote do
      map()
    end
  end

  defp to_spec("array", _refs) do
    quote do
      list()
    end
  end
end
