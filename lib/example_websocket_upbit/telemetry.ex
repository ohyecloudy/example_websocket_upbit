defmodule ExampleWebsocketUpbit.Telemetry do
  use Prometheus.Metric
  require Logger

  def init() do
    Logger.notice("telemetry init")

    :ok =
      :telemetry.attach_many(
        "websockex-telemetry",
        [
          [:connected],
          [:disconnected],
          [:frame, :received],
          [:terminate]
        ],
        &ExampleWebsocketUpbit.Telemetry.handle_event/4,
        nil
      )

    Summary.declare(name: :received_size_bytes, help: "received size in bytes")
    Counter.declare(name: :connection_total, help: "connection total")
    Counter.declare(name: :disconnection_total, help: "disconnection total")

    Counter.declare(
      name: :received_ticker_total,
      help: "received ticker total",
      labels: [:ticker]
    )

    :prometheus_httpd.start()
  end

  def handle_event([:frame, :received], %{size: size, ticker: ticker}, _metadata, _config) do
    Summary.observe([name: :received_size_bytes], size)
    Counter.inc(name: :received_ticker_total, labels: [ticker])
  end

  def handle_event([:connected], _measurements, _metadata, _config) do
    Counter.inc(name: :connection_total)
  end

  def handle_event([:disconnected], _measurements, _metadata, _config) do
    Counter.inc(name: :disconnection_total)
  end
end
