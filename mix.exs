defmodule Aoc2018Ex.MixProject do
  use Mix.Project

  def project do
    [
      app: :aoc_2018_ex,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :timex]
    ]
  end

  defp deps do
    [
      {:ex_spec, "~> 2.0", only: :test},
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:timex, "~> 3.1"},
      {:libgraph, "~> 0.7"}
    ]
  end
end
