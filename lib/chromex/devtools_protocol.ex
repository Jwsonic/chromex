defmodule Chromex.DevtoolsProtocol.Macro do
  @protocol_file "browser_protocol.json"

  defmacro __before_compile__(_env) do
    protocol_file = :chromex |> :code.priv_dir() |> Path.join(@protocol_file)

    protocol_data = protocol_file |> File.read!() |> Jason.decode!()

    domains = Enum.reject(protocol_data["domains"], &experimental?/1)

    Enum.each(domains, &build_domain_module/1)

    version_string = protocol_data["version"]["major"] <> "." <> protocol_data["version"]["minor"]

    quote location: :keep do
      @external_resource unquote(protocol_file)
      @version unquote(version_string)

      def version, do: @version
    end
  end

  defp build_domain_module(domain) do
    module_name = Module.concat(Chromex.DevtoolsProtocol, domain["domain"])

    commands =
      domain["commands"]
      |> Enum.reject(&experimental?/1)
      |> Enum.map(fn command ->
        name_underscore = atom_name(command["name"])

        required_params =
          command |> Map.get("parameters", []) |> Enum.reject(&Map.get(&1, "optional", false))

        optional_params =
          command
          |> Map.get("parameters", [])
          |> Enum.filter(&Map.get(&1, "optional", false))
          |> Enum.map(&Map.get(&1, "name"))

        opts = {:opts, [], module_name}

        signature_params =
          required_params
          |> Enum.map(&Map.get(&1, "name"))
          |> Enum.map(&atom_name/1)
          |> Enum.map(&Macro.var(&1, module_name))
          |> Kernel.++([{:\\, [], [opts, []]}])

        params =
          Enum.map(required_params, fn param ->
            name = param["name"]
            var = name |> atom_name() |> Macro.var(module_name)

            {name, var}
          end)

        quote location: :keep do
          # @spec unquote(name_underscore)(async: boolean()) :: {:ok, map()} | {:error, String.t()}
          def unquote(name_underscore)(unquote_splicing(signature_params)) do
            msg = %{
              "method" => unquote(domain["domain"]) <> "." <> unquote(command["name"]),
              "params" => %{
                unquote_splicing(params)
              }
            }

            params =
              unquote(optional_params)
              |> Enum.reduce(msg["params"], fn param, acc ->
                param_underscore = param |> Macro.underscore() |> String.to_atom()

                case Keyword.get(unquote(opts), param_underscore) do
                  nil -> acc
                  value -> Map.put(acc, param, value)
                end
              end)

            msg = Map.put(msg, "params", params)

            Chromex.Browser.send(msg, unquote(opts))
          end
        end
      end)

    contents =
      quote location: :keep do
        @moduledoc unquote(domain["description"])

        unquote(commands)
      end

    Module.create(module_name, contents, Macro.Env.location(__ENV__))
  end

  defp experimental?(map), do: Map.get(map, "experimental", false)

  defp atom_name(name) do
    name |> Macro.underscore() |> String.to_atom()
  end
end

defmodule Chromex.DevtoolsProtocol do
  @before_compile Chromex.DevtoolsProtocol.Macro
end
