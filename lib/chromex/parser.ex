defmodule Chromex.Parser do
  @spec types(list(map())) :: map()
  def types(domains) do
    # Example data
    # %{
    #   "Animation" => %{
    #     "Animation" => %{
    #       "id" => {:binary, [], []},
    #       "name" => {:binary, [], []},
    #       "pausedState" => {:boolean, [], []},
    #       "playState" => {:binary, [], []},
    #       "playbackRate" => {:|, [], [{:float, [], []}, {:integer, [], []}]},
    #       "startTime" => {:|, [], [{:float, [], []}, {:integer, [], []}]},
    #       "currentTime" => {:|, [], [{:float, [], []}, {:integer, [], []}]},
    #       "type" => {:|, [], ["CSSTransition", {:|, [], ["CSSAnimation", "WebAnimation"]}]},
    #       "source" => "AnimationEffect",
    #       "cssId" => {:binary, [], []}
    #     }
    #   }
    # }

    domain_map =
      domains
      |> Enum.reject(&Map.get(&1, "experimental", false))
      |> Enum.reduce(%{}, fn domain, acc ->
        types =
          domain["types"]
          |> Enum.reject(&Map.get(&1, "experimental", false))
          |> Enum.reduce(acc, fn type, acc ->
            Map.put(acc, type["id"], type)
          end)

        domain = Map.put(domain, "types", types)

        Map.put(acc, domain["domain"], domain)
      end)

    types =
      domain_map
      |> Enum.filter(fn {id, _domain} -> id == "Debugger" end)
      |> Enum.reduce(%{}, fn {name, domain}, acc ->
        domain_types =
          domain["types"]
          |> IO.inspect(label: :pre)
          |> Enum.reduce(%{}, fn {type_name, type}, acc ->
            spec = to_spec(type, name, domain_map)

            Map.put(acc, type_name, spec)
          end)

        Map.put(acc, name, domain_types)
      end)
      |> IO.inspect(label: :post)

    # types
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

  defp to_spec(%{"type" => type}, domain, domains) do
    to_spec(type, domain, domains)
  end

  defp to_spec(%{"$ref" => ref}, domain, domains) do
    [next_domain, type] =
      case String.split(ref, ".") do
        [type] -> [domain, type]
        [_domain, _type] = path -> path
      end

    # |> IO.inspect()

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
