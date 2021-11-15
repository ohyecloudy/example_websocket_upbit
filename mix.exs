defmodule ExampleWebsocketUpbit.MixProject do
  use Mix.Project

  def project do
    [
      app: :example_websocket_upbit,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ExampleWebsocketUpbit.Application, []}
    ]
  end

  defp deps do
    [
      {:websockex, "~> 0.4.3"},
      {:elixir_uuid, "~> 1.2"},
      {:jason, "~> 1.2"}
    ]
  end
end
