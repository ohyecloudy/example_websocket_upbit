defmodule ExampleWebsocketUpbit.Client do
  use WebSockex
  require Logger

  def start_link(url) do
    WebSockex.start_link(url, __MODULE__, :ok, name: __MODULE__)
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
    {:ok, state}
  end

  def handle_frame({type, msg}, state) do
    msg = Jason.decode!(msg)
    Logger.debug("Received Message - Type: #{inspect(type)} -- Message: #{inspect(msg)}")
    {:ok, state}
  end

  def handle_cast({:send, {type, msg} = frame}, state) do
    Logger.debug("Sending #{type} frame with payload: #{msg}")
    {:reply, frame, state}
  end
end
