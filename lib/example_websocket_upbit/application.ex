defmodule ExampleWebsocketUpbit.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    ExampleWebsocketUpbit.Telemetry.init()

    children = [
      {ExampleWebsocketUpbit.Client,
       [
         url: "wss://api.upbit.com/websocket/v1",
         tickers: Application.get_env(:example_websocket_upbit, :tickers, [])
       ]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExampleWebsocketUpbit.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
