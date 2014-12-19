defmodule BtCrawler.PeerHarvester do
  require Logger

  alias BtCrawler.MlDHT, as: MlDHT
  alias BtCrawler.DB,    as: DB

  #####
  ## External API

  def start_link(n) do
    Logger.info "#{__MODULE__} start_link #{inspect self}: #{inspect n}"
    GenServer.start_link(__MODULE__, n, name: String.to_atom("harvester#{n}"))
  end

  #####
  ## GenServer Implementation



  def harvest do
    Logger.info "#{__MODULE__} harvest"
    GenServer.call __MODULE__, :harvest
  end

  def start do
    get_peers Utils.cfg(:bootstrap_node)
  end

  def handle_cast(:start, state) do
    Logger.info "#{__MODULE__} handle_cast :start #{inspect self}"
    get_peers Utils.cfg(:bootstrap_node)
    {:noreply, state}
  end

  def handle_call(:harvest, state, _foo) do
    Logger.info "#{__MODULE__} handle_call :harvest #{inspect self}"
    get_peers Utils.cfg(:bootstrap_node)
    {:reply, "foo", state}
  end

  def init(state) do
    Logger.info "#{__MODULE__} init #{inspect self}: #{inspect state}"
    # GenServer.cast __MODULE__, :start
    # get_peers Utils.cfg(:bootstrap_node)
    {:ok, state}
  end

  #####
  ## Interal API

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
  def handle(incoming, {:ok, {msg, _foo}}, _peer) do
    Logger.info("Received message")
    Logger.info("\n" <> PrettyHex.pretty_hex(msg))
    incoming |> Socket.close

    MlDHT.parse(msg) |> add_peer
  end


  @doc """
  This function handles an unsuccessful request. It prints the error
  message and runs add_peer() again to start a new request.
  """
  def handle(incoming, {:error, reason}, peer) do
    Logger.error "Peer #{inspect peer}: #{reason}"
    incoming |> Socket.close

    add_peer([])
  end


  @doc """
  This function gets a list of peers and tries to add each of these
  into the database.
  """
  def add_peer([]) do
    Logger.info "[#{__MODULE__}] add_peer []"
    DB.Query.get_not_requested_peer
    |> Utils.ipstr_to_tupel
    |> get_peers
  end

  def add_peer([peer | tail]) do
    Logger.info "peer added: #{inspect peer}"
    peer_str  = Utils.tupel_to_ipstr(peer)
    new_entry = %DB.Peers{peer: peer_str, info_hash: "", requested: 0 }

    case DB.Peers.validate(new_entry) do
      %{peer: [{:ok}]} ->
        new_entry |> DB.Repo.insert
      %{peer: [{:error, message}]} ->
        Logger.error("Could not add new peer: #{message}")
    end

    add_peer(tail)
  end

end
