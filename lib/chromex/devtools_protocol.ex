defmodule Chromex.DevtoolsProtocol.Macro do
  @protocol_file "browser_protocol.json"

  defmacro __before_compile__(_env) do
    protocol_file = :chromex |> :code.priv_dir() |> Path.join(@protocol_file)

    protocol_data = protocol_file |> File.read!() |> Jason.decode!()

    domains = Enum.reject(protocol_data["domains"], &Map.get(&1, "experimental", false))

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
      |> Enum.reject(&Map.get(&1, "experimental", false))
      |> Enum.map(fn command ->
        name_underscore = command["name"] |> Macro.underscore() |> String.to_atom()

        quote location: :keep do
          @spec unquote(name_underscore)(async: boolean()) :: {:ok, map()} | {:error, String.t()}
          def unquote(name_underscore)(opts \\ [async: false]) do
            msg = %{
              id: 1,
              method: unquote(domain["domain"]) <> "." <> unquote(command["name"]),
              params: %{}
            }

            Chromex.Browser.send(msg, opts)
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
end

defmodule Chromex.DevtoolsProtocol do
  @before_compile Chromex.DevtoolsProtocol.Macro
end
