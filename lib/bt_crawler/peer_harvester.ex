defmodule BtCrawler.PeerHarvester do
  require Logger

  alias BtCrawler.MlDHT, as: MlDHT
  alias BtCrawler.DB,    as: DB

  #####
  ## External API

  @doc """
  This function starts the DHT crawler.
  """
  def start do
    Logger.info "#{__MODULE__} start (#{inspect self})"
    get_peers Utils.cfg(:bootstrap_node), 1
  end

  #####
  ## Interal API

  @doc """
  This function gets a fresh peer and starts a DHT find_node request
  to it. If this function gets executed n times, it will exit with
  :finish.
  """
  def get_peers(_peer, n) when n == 10 do
    Logger.info "finish"
    exit(:finish)
  end

  def get_peers(peer, n) do
    Logger.info "request peer: #{inspect peer} (#{n})"
    payload  = MlDHT.get_peers Utils.cfg(:node_id), Utils.hex_to_str(Utils.cfg(:info_hash))
    incoming = Socket.UDP.open!

    Socket.Datagram.send(incoming, payload, peer)
    run(incoming, peer, n)
  end


  defp run(incoming, peer, n) do
    msg = receive_msg(incoming)
    handle(incoming, msg, peer, n)
  end

  defp receive_msg(incoming) do
    Socket.Datagram.recv(incoming, 0, [timeout: 5000])
  end

  @doc """
  This function handles an successful request. It prints the received
  message in hex and calls the Mainline DHT parser.
  """
  def handle(incoming, {:ok, {msg, _foo}}, _peer, n) do
    Logger.info("Received message")
    Logger.info("\n" <> PrettyHex.pretty_hex(msg))
    incoming |> Socket.close

    MlDHT.parse(msg) |> add_peer(n)
  end


  @doc """
  This function handles an unsuccessful request. It prints the error
  message and runs add_peer() again to start a new request.
  """
  def handle(incoming, {:error, reason}, peer, n) do
    Logger.error "Peer #{inspect peer}: #{reason}"
    incoming |> Socket.close

    add_peer([], n)
  end



  @doc """
  This function gets a list of peers and tries to add each of these
  into the database.
  """
  def add_peer([], n) do
    Logger.info "[#{__MODULE__}] add_peer []"
    DB.Query.get_not_requested_peer
    |> Utils.ipstr_to_tupel
    |> get_peers(n+1)
  end

  def add_peer([peer | tail], n) do
    Logger.info "peer added: #{inspect peer}"
    peer_str  = Utils.tupel_to_ipstr(peer)
    new_entry = %DB.Peers{peer: peer_str, info_hash: "", requested: 0 }

    case DB.Peers.validate(new_entry) do
      {:ok} ->
        new_entry |> DB.Repo.insert
      {:error, message} ->
        Logger.error("Could not add new peer: #{message}")
    end

    add_peer(tail, n)
  end

end
