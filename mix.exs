defmodule Slop.MixProject do
  use Mix.Project

  def project do
    [
      app: :slop,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Deps
      {:phoenix, "~> 1.7.0", optional: true},
      {:jason, "~> 1.4", optional: true},
      {:plug, "~> 1.15", optional: true},
      {:httpoison, "~> 2.0", optional: true},
      # Testing
      {:credo, "~> 1.7", only: [:dev, :test]},
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
      {:doctor, "~> 0.22.0", only: [:dev, :test]},
      {:ex_check, "~> 0.12", only: [:dev, :test]},
      {:ex_doc, "~> 0.37-rc", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.18.3", only: [:dev, :test]},
      {:expublish, "~> 2.5", only: [:dev], runtime: false},
      {:git_ops, "~> 2.5", only: [:dev, :test]},
      {:igniter, "~> 0.5", only: [:dev, :test]},
      {:mimic, "~> 1.7", only: [:dev, :test]},
      {:mix_audit, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false},
      {:sobelow, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:stream_data, "~> 1.1", only: [:dev, :test]},
    ]
  end

  defp description do
    """
    A Phoenix router extension that implements the SLOP (Simple Language Open Protocol)
    for AI service interactions.
    """
  end

  defp package do
    [
      maintainers: ["Mike Hostetler"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/mikehostetler/slop"},
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE)
    ]
  end

  defp docs do
    [
      main: "readme",
      name: "SLOP for Phoenix",
      source_url: "https://github.com/mikehostetler/slop",
      extras: ["README.md"],
      groups_for_modules: [
        "Core": [
          Slop,
          Slop.Router,
          Slop.Controller
        ],
        "Utilities": [
          Slop.Streaming,
          Slop.Client
        ],
        "Examples": [
          Slop.ExampleRouter
        ]
      ]
    ]
  end
end
