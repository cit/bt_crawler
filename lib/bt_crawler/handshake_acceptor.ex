defmodule BtCrawler.HandshakeAcceptor do
  require Logger

  def listen(port) do
    Logger.info "#{__MODULE__} listen on port #{port}"

    opts = [{:reuseaddr, true}]
    {:ok, listening_socket} = Socket.UDP.open(port, opts)
    listening_socket |> run
  end

  def run(listening_socket) do
    msg = receive_msg(listening_socket)
    handle(listening_socket, msg)
  end

  def receive_msg(listening_socket) do
    Socket.Datagram.recv(listening_socket, 0, [])
  end

  def handle(listening_socket, {:ok, {msg, _foo}}) do
    Logger.info "received message"
    Logger.info "#{inspect msg}"

    if msg == "exit\n" do
      exit(:FOO)
    end

    run(listening_socket)
  end



end
