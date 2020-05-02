# defmodule Chromex.DevtoolsProtocol.Macro do
#   @protocol_files ["browser_protocol.json", "js_protocol.json"]

#   defmacro __before_compile__(_env) do
#     domains =
#       @protocol_files
#       |> Enum.map(fn file_name ->
#         :chromex |> :code.priv_dir() |> Path.join(file_name)
#       end)
#       |> Enum.map(&File.read!/1)
#       |> Enum.map(&Jason.encode!/1)
#       |> Enum.flat_map(&Map.get(&1, "domains", []))
#       |> Enum.filter(&stable?/1)
#       |> Enum.map(fn domain ->
#         commands = Enum.filter(domain["commands"], &stable?/1)
#         types = Enum.filter(domain["types"], &stable?/1)
#         events = Enum.filter(domain["events"], &stable?/1)

#         %{domain | "commands" => commands, "events" => events, "types" => types}
#       end)

#     # protocol_data = protocol_file |> File.read!() |> Jason.decode!()

#     # domains = Enum.reject(protocol_data["domains"], &experimental?/1)

#     # Chromex.Parser.types(domains)

#     # Enum.each(domains, &build_domain_module(&1, types))

#     quote location: :keep do
#       @version "1.3"

#       def version, do: @version
#     end
#   end

#   defp build_domain_module(domain, types) do
#     module_name = Module.concat(Chromex.DevtoolsProtocol, domain["domain"])

#     IO.inspect(domain["domain"])

#     commands =
#       domain["commands"]
#       |> Enum.reject(&experimental?/1)
#       |> Enum.map(fn command ->
#         name_underscore = atom_name(command["name"])

#         required_params =
#           command |> Map.get("parameters", []) |> Enum.reject(&Map.get(&1, "optional", false))

#         optional_params =
#           command
#           |> Map.get("parameters", [])
#           |> Enum.filter(&Map.get(&1, "optional", false))

#         opts = {:opts, [], module_name}

#         signature_params =
#           required_params
#           |> Enum.map(&Map.get(&1, "name"))
#           |> Enum.map(&atom_name/1)
#           |> Enum.map(&Macro.var(&1, module_name))
#           |> Kernel.++([{:\\, [], [opts, []]}])

#         spec_opts =
#           optional_params
#           |> Enum.map(fn param ->
#             name_underscore = atom_name(param["name"])

#             # to_spec(param, types)
#             spec = nil

#             quote(do: Keyword.new([{unquote(name_underscore), unquote(spec)}]))
#           end)

#         spec_params = Enum.map(required_params, &to_spec(&1, types)) ++ [spec_opts]

#         msg_params =
#           Enum.map(required_params, fn param ->
#             name = param["name"]
#             var = name |> atom_name() |> Macro.var(module_name)

#             {name, var}
#           end)

#         quote location: :keep do
#           @spec unquote(name_underscore)(unquote_splicing(spec_params)) ::
#                   {:ok, map()} | {:error, String.t()}
#           def unquote(name_underscore)(unquote_splicing(signature_params)) do
#             msg = %{
#               "method" => unquote(domain["domain"]) <> "." <> unquote(command["name"]),
#               "params" => %{
#                 unquote_splicing(msg_params)
#               }
#             }

#             msg_params =
#               unquote(Enum.map(optional_params, &Map.get(&1, "name")))
#               |> Enum.reduce(msg["params"], fn param, acc ->
#                 param_underscore = param |> Macro.underscore() |> String.to_atom()

#                 case Keyword.get(unquote(opts), param_underscore) do
#                   nil -> acc
#                   value -> Map.put(acc, param, value)
#                 end
#               end)

#             msg = Map.put(msg, "params", msg_params)

#             Chromex.Browser.send(msg, unquote(opts))
#           end
#         end
#       end)

#     contents =
#       quote location: :keep do
#         @moduledoc unquote(domain["description"])

#         unquote(commands)
#       end

#     Module.create(module_name, contents, Macro.Env.location(__ENV__))
#   end

#   defp stable?(%{"experimental" => true}), do: false
#   defp stable?(%{"deprecated" => true}), do: false
#   defp stable?(_map), do: true

#   defp atom_name(name) do
#     name |> Macro.underscore() |> String.to_atom()
#   end

#   defp to_spec(_, _), do: nil
# end

# defmodule Chromex.DevtoolsProtocol do
#   @before_compile Chromex.DevtoolsProtocol.Macro
# end
