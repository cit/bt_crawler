require Logger

defmodule BtCrawler.CLI do
  alias BtCrawler.MlDHT, as: MlDHT
  alias BtCrawler.DB,    as: DB


  def main(_argv) do
    Logger.info "BitTorrent Crawler started"

    ## start with the boostraping node from our config
    get_peers Utils.cfg(:bootstrap_node)
  end

  def get_peers(peer) do
    Logger.info "request peer: #{inspect peer}"
    payload  = MlDHT.get_peers Utils.cfg(:node_id), Utils.hex_to_str(Utils.cfg(:info_hash))
    incoming = Socket.UDP.open!

    Socket.Datagram.send(incoming, payload, peer)
    run(incoming, peer)
  end

  defp run(incoming, peer) do
    msg = receive_msg(incoming)
    handle(incoming, msg, peer)
  end

  defp receive_msg(incoming) do
    Socket.Datagram.recv(incoming, 0, [timeout: 5000])
  end

  @doc """
  This function handles an successful request. It prints the received
  message in hex and calls the Mainline DHT parser.
  """
  def handle(_, {:ok, {msg, _foo}}, _peer) do
    Logger.info("Received message")
    Logger.info("\n" <> PrettyHex.pretty_hex(msg))

    MlDHT.parse(msg) |> add_peer
  end


  @doc """
  This function handles an unsuccessful request. It prints the error
  message and runs add_per() again to start a new request.
  """
  def handle(_incoming, {:error, reason}, peer) do
    Logger.error "Peer #{inspect peer}: #{reason}"

    add_peer([])
  end


  defp add_peer([]) do
    [entry] = DB.Query.get_not_requested_peer
    peer = Utils.ipstr_to_tupel(entry.peer)

    updated_entry = %DB.Peers{entry | requested: 1}
    DB.Repo.update(updated_entry)

    get_peers peer
  end

  defp add_peer([peer | tail]) do
    Logger.info inspect peer
    peer_entry = %DB.Peers{
                   peer: Utils.tupel_to_ipstr(peer),
                   info_hash: "",
                   requested: 0
               }
    DB.Repo.insert(peer_entry)
    add_peer(tail)
  end


end
