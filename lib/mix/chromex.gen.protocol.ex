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
      |> Enum.map(&path_priv_file/1)
      |> Enum.map(&File.read!/1)
      |> Enum.map(&Jason.decode!/1)
      |> Enum.flat_map(&Map.get(&1, "domains", []))
      |> Enum.filter(&stable?/1)
      |> Enum.map(fn domain ->
        domain
        |> stabilize("commands", "name")
        |> stabilize("events", "name")
      end)
      |> key_by("domain")

    File.rm_rf!(@file_dir)
    File.mkdir_p!(@file_dir)

    Enum.each(domains, fn {_name, domain} -> build_module(domain) end)

    System.cmd("mix", ["format"])
    :ok
  end

  @function_template "function_template.eex"

  defp build_module(%{"domain" => name, "commands" => commands, "types" => types} = domain) do
    module_name = String.capitalize(name)

    module_doc =
      domain
      |> Map.get("description", "")
      |> format_lines()

    allowed_types = MapSet.new(types)

    include_reduce_opts = reduce_opts_needed?(domain)

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
            Macro.underscore(name) <> ": " <> to_spec(msg)
          end)

        spec_params =
          required_params
          |> Enum.map(fn %{"name" => name} = param ->
            spec = to_spec(param)

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

        @function_template
        |> path_priv_file()
        |> EEx.eval_file(bindings)
      end)

    types =
      types
      |> Enum.map(fn type ->
        name =
          type |> Map.get("id") |> Macro.underscore() |> (&Map.get(@reserved_names, &1, &1)).()

        spec = to_spec(type)

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

    bindings = [
      functions: functions,
      include_reduce_opts: include_reduce_opts,
      module_doc: module_doc,
      module_name: module_name,
      types: types
    ]

    write_file(module_name, bindings)
  end

  defp path_priv_file(file_name) do
    :chromex |> :code.priv_dir() |> Path.join(file_name)
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

  defp to_spec(%{"type" => "object", "properties" => properties}) do
    specs =
      properties
      |> Enum.map(&to_spec/1)
      |> Enum.zip(properties)
      |> Enum.map(fn
        {spec, %{"name" => prop, "optional" => true}} -> "optional(:\"#{prop}\") => #{spec}"
        {spec, %{"name" => prop}} -> "required(:\"#{prop}\") => #{spec}"
      end)
      |> Enum.join(", ")

    "%{#{specs}}"
  end

  defp to_spec(%{"$ref" => ref}) do
    case String.split(ref, ".") do
      [ref] ->
        ref |> Macro.underscore() |> Kernel.<>("()")

      [module, ref] ->
        ref = Macro.underscore(ref)
        "#{module}.#{ref}()"
    end
  end

  defp to_spec(%{"type" => "array", "items" => type}) do
    spec = to_spec(type)

    "[#{spec}]"
  end

  @specs %{
    "boolean" => "boolean()",
    "integer" => "integer()",
    "number" => "integer() | float()",
    "string" => "String.t()",
    "object" => "map()",
    "any" => "any()"
  }

  defp to_spec(%{"type" => type}) do
    Map.get(@specs, type, "broken_type")
  end

  # Split a string into lines of max_line_len length
  defp format_lines(string, max_line_len \\ 80) do
    string
    |> String.trim()
    |> String.replace("\n", " ")
    |> String.split(" ")
    |> Enum.chunk_while(
      "",
      fn word, acc ->
        acc = acc <> " " <> word

        case String.length(acc) <= max_line_len do
          true -> {:cont, acc}
          false -> {:cont, acc, ""}
        end
      end,
      fn acc -> {:cont, acc, ""} end
    )
  end

  defp reduce_opts_needed?(%{"commands" => commands, "types" => types}) do
    allowed_types = MapSet.new(types)

    commands
    |> Enum.flat_map(fn {_name, command} -> Map.get(command, "parameters", []) end)
    |> Enum.filter(&Map.get(&1, "optional", false))
    |> Enum.filter(fn
      %{"$ref" => ref} -> MapSet.member?(allowed_types, ref)
      _ -> true
    end)
    |> length()
    |> Kernel.>(0)
  end

  @module_template "module_template.eex"

  defp write_file(module_name, bindings) do
    content = @module_template |> path_priv_file() |> EEx.eval_file(bindings)

    file_name = module_name |> Macro.underscore() |> Kernel.<>(".ex")

    @file_dir
    |> Path.join(file_name)
    |> File.write!(content)
  end
end
