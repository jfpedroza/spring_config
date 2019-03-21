defmodule SpringConfig.MixProject do
  use Mix.Project

  @version "0.1.1"

  def project do
    [
      app: :spring_config,
      version: @version,
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      name: "SpringConfig",
      description: description(),
      package: package(),
      deps: deps(),
      docs: docs(),
      source_url: "https://github.com/johnf9896/spring_config"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {SpringConfig.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.18", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0-rc.4", only: [:dev], runtime: false},
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:poison, "~> 3.1"},
      {:pattern_tap, "~> 0.4"},
      {:httpoison, "~> 1.4"},
      {:yaml_elixir, "~> 2.1.0"}
    ]
  end

  defp description() do
    "Consume configuration from a Spring Cloud Config Server in Elixir."
  end

  defp docs do
    [
      source_ref: "v#{@version}",
      main: "readme",
      extras: ["README.md"]
    ]
  end

  defp package() do
    [
      maintainers: ["Jhon Pedroza"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/johnf9896/spring_config"}
    ]
  end
end
