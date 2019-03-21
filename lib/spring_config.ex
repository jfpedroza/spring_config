defmodule SpringConfig do
  @moduledoc """
  Consume configuration from a Spring Cloud Config Server in Elixir.
  """

  use PatternTap

  @default_opts []

  @spec get(atom(), any(), keyword()) :: any()
  @doc """
  Finds and returns `key` in the configuration registry. If `key` is not found, `default` is returned.

  Available options are:
    - `ensure_started`: Uses `Application.ensure_all_started/2` to start the SpringConfig application
    temporarily in case the process is not part of the supervision tree. Default `false`.
  """
  def get(key, default \\ nil, opts \\ []) when is_atom(key) do
    opts = Keyword.merge(@default_opts, opts)

    if opts[:ensure_started] do
      {:ok, _} = Application.ensure_all_started(:spring_config)
    end

    key |> to_string() |> String.split(".") |> Enum.map(&String.to_atom/1) |> do_get(default)
  end

  @spec get!(atom(), keyword()) :: any()
  @doc """
  Similar to `get/3` but raises if `key` is not found.
  """
  def get!(key, opts \\ []) when is_atom(key) do
    case get(key, :default_value, opts) do
      :default_value ->
        raise "Key #{key} not found in configuration entries"

      value ->
        value
    end
  end

  defp do_get(keys, default) do
    case :ets.select(:spring_config, [{{keys ++ :"$1", :"$2"}, [], [{{:"$1", :"$2"}}]}]) do
      [] ->
        default

      result ->
        transform(result)
    end
  end

  defp transform(entries) do
    Enum.reduce(entries, %{}, fn
      {[], value}, _out ->
        value

      {keys, value}, map ->
        map
        |> create_path(keys)
        |> put_in(keys, value)
    end)
  end

  defp create_path(map, keys) do
    keys
    |> Enum.reduce({map, []}, fn
      key, {map, []} ->
        {Map.put_new(map, key, nil), [key]}

      key, {map, prev_keys} ->
        new_map =
          update_in(map, prev_keys, fn
            nil -> %{key => nil}
            val -> val
          end)

        {new_map, prev_keys ++ [key]}
    end)
    |> tap({map, _} ~> map)
  end
end
