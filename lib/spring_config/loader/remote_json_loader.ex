defmodule SpringConfig.Loader.RemoteJsonLoader do
  @moduledoc """
    Loads configuration from a Spring Cloud Configuration Server
  """

  alias SpringConfig.Loader.LoaderBehaviour

  @behaviour LoaderBehaviour

  @impl LoaderBehaviour
  @spec load(keyword()) :: no_return()
  @doc """
   Loads configuration from a Spring Cloud Configuration Server.
   It will make an HTTP GET request to a URL of the form `host/app_name/profile`.

  Accepted options:
  - `host`: The base url of the configuration server, e.g.: `http://locahost:9888/config-service`,
  - `app_name`: The name of the application to look up, it corresponds to the name of YAML file in the git configuration repository,
  - `profile`: The profile to use to filter the configuration. It will use spring.profiles to filter
  and if it's not present, the document will be included,
  - `ets_table`: The name of the ETS table to push the entries into.
  """
  def load(opts) when is_list(opts) do
    opts |> request() |> fetch_entries(opts) |> push_into_ets(opts)
  end

  defp request(opts) do
    host = Keyword.fetch!(opts, :host)
    app_name = Keyword.fetch!(opts, :app_name)
    profile = Keyword.fetch!(opts, :profile)
    url = "#{host}/#{app_name}/#{profile}"

    case HTTPoison.get!(url) do
      %HTTPoison.Response{body: body, headers: _, status_code: status_code}
      when status_code <= 299 ->
        Poison.Parser.parse!(body)

      %HTTPoison.Response{body: body, headers: _, status_code: status_code}
      when status_code >= 400 ->
        raise "Error while connecting to the ConfigServer. Status code: #{status_code}\n#{
                inspect(body)
              }"
    end
  end

  defp fetch_entries(response, _opts) do
    List.foldr(response["propertySources"], [], fn doc, entries ->
      Enum.concat(entries, doc["source"])
    end)
  end

  defp push_into_ets(entries, opts) when is_list(entries) do
    Enum.each(entries, &push_into_ets(&1, opts))
  end

  defp push_into_ets({key, value}, opts) do
    table = Keyword.fetch!(opts, :ets_table)
    keys = key |> String.split(".") |> Enum.map(&String.to_atom/1)
    :ets.insert(table, {keys, value})
  end
end
