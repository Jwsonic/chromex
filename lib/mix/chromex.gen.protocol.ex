defmodule Mix.Tasks.Chromex.Gen.Protocol do
  use Mix.Task

  @protocol_files ["browser_protocol.json", "js_protocol.json"]

  @file_dir Path.join(["lib", "chromex", "devtools_protocol"])

  @reserved_names %{
    "end" => "end_",
    "node" => "node_"
  }

  def run(_args) do
    domains =
      @protocol_files
      |> Enum.map(fn file_name ->
        :chromex |> :code.priv_dir() |> Path.join(file_name)
      end)
      |> Enum.map(&File.read!/1)
      |> Enum.map(&Jason.decode!/1)
      |> Enum.flat_map(&Map.get(&1, "domains", []))
      |> Enum.filter(&stable?/1)
      |> Enum.map(fn domain ->
        domain
        |> stabilize("commands", "name")
        |> stabilize("types", "id")
        |> stabilize("events", "name")
      end)
      |> key_by("domain")

    File.rm_rf!(@file_dir)
    File.mkdir_p!(@file_dir)

    Enum.each(domains, fn {_name, domain} -> build_module(domains, domain) end)

    System.cmd("mix", ["format"])
    :ok
  end

  @template """
  defmodule Chromex.DevtoolsProtocol.<%= module_name %> do
    @moduledoc \"\"\"
  <%= for line <- module_doc do %>  <%= line %><% end %>
    \"\"\"


    <%= types %>


    <%= functions %>


    <%= if include_reduce_opts do %>
    defp reduce_opts(keys, opts) do
      keys
      |> Enum.map(fn key -> {key, Keyword.get(opts, key, :missing)} end)
      |> Enum.reduce(%{}, fn
        {_key, :missing}, acc -> acc
        {key, value}, acc -> Map.put(acc, key, value)
      end)
    end
    <% end %>
  end
  """

  @function_template """
  @doc \"\"\"
    <%= doc %>
  \"\"\"
  @spec <%= name %>(<%= spec_params %>) :: <%= spec_result %>
  def <%= name %>(<%= signature_params %> opts \\\\ []) do
    msg = %{
      <%= msg_contents %>
    }


    async = Keyword.get(opts, :async, false)

    <%= if param_keys != "" do %>
    params = reduce_opts([<%= param_keys %>], opts)


    msg
    |> Map.put("params", params)
    |> Chromex.Browser.send([async: async])
    <% else %>

    Chromex.Browser.send(msg, [async: async])
    <% end %>
  end
  """

  defp build_module(
         domains,
         %{"domain" => name, "commands" => commands, "types" => types} = domain
       ) do
    module_name = String.capitalize(name)

    module_doc =
      domain
      |> Map.get("description", "")
      |> String.trim()
      |> String.replace("\n", " ")
      |> String.split(" ")
      |> Enum.chunk_while(
        "",
        fn word, acc ->
          acc = acc <> " " <> word

          case String.length(acc) <= 80 do
            true -> {:cont, acc}
            false -> {:cont, acc, ""}
          end
        end,
        fn acc -> {:cont, acc, ""} end
      )

    allowed_types = MapSet.new(types, &elem(&1, 0))

    include_reduce_opts =
      commands
      |> Enum.flat_map(fn {_name, command} -> Map.get(command, "parameters", []) end)
      |> Enum.filter(&Map.get(&1, "optional", false))
      |> Enum.filter(fn
        %{"$ref" => ref} -> MapSet.member?(allowed_types, ref)
        _ -> true
      end)
      |> length()
      |> Kernel.>(0)

    functions =
      commands
      |> Enum.map(fn {name, command} ->
        doc =
          command
          |> Map.get("description", "")
          |> String.replace("\n", "")
          |> String.replace("`", "'")

        parameters = Map.get(command, "parameters", [])

        parameters |> Enum.map(&Map.get(&1, "name"))

        required_params = parameters |> Enum.reject(&Map.get(&1, "optional", false))

        optional_params =
          parameters
          |> Enum.filter(&Map.get(&1, "optional", false))
          |> Enum.filter(fn
            %{"$ref" => ref} -> MapSet.member?(allowed_types, ref)
            _ -> true
          end)

        param_keys =
          optional_params
          |> Enum.map(&Map.get(&1, "name"))
          |> Enum.map(&Map.get(@reserved_names, &1, &1))
          |> Enum.map(&Macro.underscore/1)
          |> Enum.map(&String.to_atom/1)
          |> Enum.map(&inspect/1)
          |> Enum.join(", ")

        opt_spec_params =
          optional_params
          |> Kernel.++([%{"name" => "async", "type" => "boolean"}])
          |> Enum.map(fn %{"name" => name} = msg ->
            Macro.underscore(name) <> ": " <> to_spec(msg, domains)
          end)

        spec_params =
          required_params
          |> Enum.map(fn %{"name" => name} = param ->
            spec = to_spec(param, domains)

            "#{name} :: #{spec}"
          end)
          |> Enum.concat(opt_spec_params)
          |> Enum.join(", ")

        signature_params =
          required_params
          |> Enum.map(&Map.get(&1, "name"))
          |> Enum.map(&Map.get(@reserved_names, &1, &1))
          |> Enum.map(&Macro.underscore/1)

        msg_contents =
          required_params
          |> Enum.map(&Map.get(&1, "name"))
          |> Enum.zip(signature_params)
          |> Enum.map(fn {key, val} -> "\"#{key}\" => #{val}" end)
          |> Enum.join(",\n")

        signature_params = join_params(signature_params)

        bindings = [
          doc: doc,
          msg_contents: msg_contents,
          name: Macro.underscore(name),
          param_keys: param_keys,
          signature_params: signature_params,
          spec_params: spec_params,
          spec_result: "%{}"
        ]

        EEx.eval_string(@function_template, bindings)
      end)
      |> Enum.join("\n\n")

    types =
      types
      |> Enum.map(fn {name, type} ->
        name = name |> Macro.underscore() |> (&Map.get(@reserved_names, &1, &1)).()
        spec = to_spec(type, domains)

        doc =
          type
          |> Map.get("description", "")
          |> String.replace("\n", "")
          |> String.replace("`", "'")

        prepend =
          case doc do
            "" -> ""
            _ -> "# "
          end

        "#{prepend}#{doc}\n@type #{name} :: #{spec}"
      end)
      |> Enum.join("\n\n")

    bindings = [
      functions: functions,
      include_reduce_opts: include_reduce_opts,
      module_doc: module_doc,
      module_name: module_name,
      types: types
    ]

    content = EEx.eval_string(@template, bindings)

    file_name = name |> Macro.underscore() |> Kernel.<>(".ex")

    @file_dir
    |> Path.join(file_name)
    |> File.write!(content)
  end

  defp stabilize(domain, sub_domain, key) do
    stable =
      domain
      |> Map.get(sub_domain, [])
      |> Enum.filter(&stable?/1)
      |> key_by(key)

    Map.put(domain, sub_domain, stable)
  end

  defp stable?(%{"experimental" => true}), do: false
  defp stable?(%{"deprecated" => true}), do: false
  defp stable?(_map), do: true

  defp key_by(enumerable, key) do
    Enum.reduce(enumerable, %{}, fn map, acc ->
      Map.put(acc, map[key], map)
    end)
  end

  defp join_params([]), do: ""

  defp join_params(params) do
    params |> Enum.join(", ") |> Kernel.<>(", ")
  end

  @specs %{
    "boolean" => "boolean()",
    "integer" => "integer()",
    "number" => "integer() | float()",
    "string" => "String.t()"
  }

  defp to_spec(%{"type" => type}, domains) do
    to_spec(type, domains)
  end

  defp to_spec(%{"$ref" => ref}, _domains) do
    case String.split(ref, ".") do
      [ref] ->
        ref |> Macro.underscore() |> Kernel.<>("()")

      [module, ref] ->
        ref = Macro.underscore(ref)
        "#{module}.#{ref}()"
    end
  end

  defp to_spec(type, _domains) when is_bitstring(type) do
    Map.get(@specs, type, "String.t()")
  end
end