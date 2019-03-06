defmodule SpringConfig.Loader do
  @moduledoc """
    Loads the configuration from the ConfigServer
  """
  alias SpringConfig.Loader.YamlLoader
  alias SpringConfig.Loader.RemoteJsonLoader

  def load() do
    :ets.new(:spring_config, [:set, :protected, :named_table])

    otp_app = fetch_config(:otp_app, true)
    path = fetch_config(:path, false, "priv/application.yml")
    app_name = fetch_config(:app_name, true)
    profile = fetch_config(:profile, true)

    YamlLoader.load(
      app: otp_app,
      path: path,
      profile: profile,
      ets_table: :spring_config
    )

    RemoteJsonLoader.load(
      host: SpringConfig.get!(:"spring.cloud.config.uri", ensure_started: false),
      app_name: app_name,
      profile: profile,
      ets_table: :spring_config
    )
  end

  defp fetch_config(key, required, default \\ nil) do
    case Application.fetch_env(:spring_config, key) do
      {:ok, {:system, env_key, default}} ->
        System.get_env(env_key) || default

      {:ok, {:system, env_key}} ->
        System.get_env(env_key) || raise "Missing #{env_key} environment variable"

      {:ok, value} ->
        value

      :error ->
        if required do
          raise "Missing required key #{key}"
        else
          default
        end
    end
  end
end
