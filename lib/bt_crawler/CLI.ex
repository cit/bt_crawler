require Logger

defmodule BtCrawler.CLI do
  alias BtCrawler.MlDHT, as: MlDHT

  def main(_argv) do
    Logger.info("Hello World")

    payload = MlDHT.find_node(Utils.cfg(:node_id), "bbbbbbbbbbbbbbbbbbbb")
    incoming = Socket.UDP.open!
    Socket.Datagram.send(incoming, payload, Utils.cfg(:bootstrap_node))
    run(incoming)
  end

  defp run(incoming) do
    msg = receive_msg(incoming)
    handle(incoming, msg)
    run(incoming)
  end

  defp receive_msg(incoming) do
    { :ok, { msg, _ } } = Socket.Datagram.recv(incoming)
    msg
  end

  defp handle(_incoming, msg) when is_binary(msg) do
    Logger.info("Received message")
    Logger.info("\n" <>PrettyHex.pretty_hex(msg))
    MlDHT.parse(msg)
  end


end
