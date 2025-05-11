defmodule Jiken.MixProject do
  use Mix.Project

  @source_url "https://github.com/NicolayD/jiken"
  @version "0.0.1"

  def project do
    [
      app: :jiken,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :dev,
      description: description(),
      deps: deps(),
      package: package(),
      docs: docs(),
      name: "Jiken",
      source_url: @source_url
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Jiken.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.34", only: :dev, runtime: false, warn_if_outdated: true},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end

  defp description() do
    """
    `Jiken` allows developers to simulate failures in their Mix applications in development. 

    Different functions can be configured to fail with specific errors, and revert to their normal operation after.

    The main aim of `Jiken` is to be able to test critical interfaces with breaking scenarios.

    It is intended to be used in development, but eventually the goal is to support staging usage as well.
    """
  end

  defp package() do
    [
      name: "jiken",
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE.md),
      licenses: ["MIT"],
      maintainers: ["Nikolay Dyulgerov"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs do
    [
      extras: [
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      formatters: ["html"]
    ]
  end
end
