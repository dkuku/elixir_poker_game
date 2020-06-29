defmodule Poker.MixProject do
  use Mix.Project

  def project do
    [
      app: :poker_game,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "poker_game",
      source_url: "https://github.com/dkuku/elxir_poker_game"
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
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:card_deck, "~> 0.1.0"}
    ]
  end

  defp description() do
    "Implements poker game logic"
  end

    defp package() do
    [
      # These are the default files included in the package
      files: ~w(lib .formatter.exs mix.exs README*),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" =>  "https://github.com/dkuku/elxir_poker_game"}
    ]
  end
end
