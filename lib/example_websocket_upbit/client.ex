defmodule ExampleWebsocketUpbit.Client do
  use WebSockex
  require Logger

  @ping_interval_ms 30_000

  defstruct [:ping_tick_timer]

  def start_link(url) do
    WebSockex.start_link(url, __MODULE__, %__MODULE__{}, name: __MODULE__)
  end

  def request_tickers(tickers) do
    [
      %{ticket: UUID.uuid4()},
      %{type: "ticker", codes: tickers}
    ]
    |> Jason.encode!()
    |> send_message()
  end

  def send_message(msg) do
    WebSockex.cast(__MODULE__, {:send, {:text, msg}})
  end

  def handle_connect(_conn, state) do
    Logger.notice("Connected!")
    :telemetry.execute([:connected], %{time: System.system_time()})

    nil = state.ping_tick_timer
    {:ok, timer} = :timer.send_interval(@ping_interval_ms, self(), :tick)
    {:ok, put_in(state.ping_tick_timer, timer)}
  end

  def handle_disconnect(_conn, state) do
    Logger.notice("Disconnected!")
    :telemetry.execute([:disconnected], %{time: System.system_time()})

    {:ok, :cancel} = :timer.cancel(state.ping_tick_timer)
    {:ok, put_in(state.ping_tick_timer, nil)}
  end

  def handle_pong(:pong, state) do
    {:ok, state}
  end

  def handle_frame({_type, org_msg}, state) do
    msg = Jason.decode!(org_msg)

    :telemetry.execute([:frame, :received], %{
      time: System.system_time(),
      size: byte_size(org_msg),
      ticker: msg["code"]
    })

    {:ok, state}
  end

  def handle_cast({:send, {type, msg} = frame}, state) do
    Logger.debug("Sending #{type} frame with payload: #{msg}")
    {:reply, frame, state}
  end

  def handle_cast({:send, type}, state) do
    Logger.debug("Sending #{type} frame with no payload")
    {:reply, type, state}
  end

  def handle_info(:tick, state) do
    {:reply, :ping, state}
  end
end
