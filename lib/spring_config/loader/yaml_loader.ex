defmodule SpringConfig.Loader.YamlLoader do
  @moduledoc """
    Loads configuration from a local Yaml file in the priv directory
  """

  alias SpringConfig.Loader.LoaderBehaviour

  @behaviour LoaderBehaviour

  @impl LoaderBehaviour
  @spec load(keyword()) :: no_return()
  @doc """
  Loads configuration from a local Yaml file in the priv directory.

  Accepted options:
  - `app`: The OTP app that contains the YAML file,
  - `path`: The path to the file inside the application. It should be in the priv directiory,
  - `profile`: The profile to use to filter the configuration. It will use spring.profiles to filter
  and if it's not present, the document will be included,
  - `ets_table`: The name of the ETS table to push the entries into.
  """
  def load(opts) when is_list(opts) do
    check_path(opts)
    |> read(opts)
    |> filter_docs(opts)
    |> push_into_ets(opts)
  end

  defp check_path(opts) do
    app = Keyword.fetch!(opts, :app)
    path = Keyword.fetch!(opts, :path)
    full_path = Application.app_dir(app, path)

    if File.exists?(full_path) do
      full_path
    else
      raise "Failed to find file #{path} in #{app}"
    end
  end

  defp read(path, _opts), do: YamlElixir.read_all_from_file!(path)

  defp filter_docs(docs, opts) do
    profile = Keyword.fetch!(opts, :profile)

    Enum.filter(docs, fn doc ->
      if profiles = doc["spring"]["profiles"] do
        profiles
        |> String.split(",", trim: true)
        |> Enum.map(&String.trim/1)
        |> Enum.member?(profile)
      else
        true
      end
    end)
  end

  defp push_into_ets(docs, opts) when is_list(docs) do
    Enum.each(docs, &push_into_ets(&1, opts))
  end

  defp push_into_ets(doc, opts) when is_map(doc) do
    Enum.each(doc, fn {key, value} -> push_into_ets([key], value, opts) end)
  end

  defp push_into_ets(keys, value, opts) when is_list(keys) and is_map(value) do
    Enum.each(value, fn {key, val} -> push_into_ets(keys ++ [key], val, opts) end)
  end

  defp push_into_ets(keys, value, opts) when is_list(keys) do
    table = Keyword.fetch!(opts, :ets_table)
    keys = Enum.map(keys, &String.to_atom/1)
    :ets.insert(table, {keys, value})
  end
end
