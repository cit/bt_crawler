defmodule BtCrawler.HandshakeAcceptor do
  require Logger

  alias BtCrawler.UTP
  alias BtCrawler.Utils
  alias BtCrawler.DB

  @module "[HandshakeAcceptor]"
  @conn_id_recv 17767
  @conn_id_send 17768
  @seq_nr 9000

  def listen(nil) do
    Logger.info "#{@module} sleeps for a second: zzZzz"
    :timer.sleep 5000
  end


  def listen({socket, info_hash, node_id}) do
    Logger.info "#{@module} start (#{inspect self}) with #{socket} infohash: #{info_hash}"

    {:ok, listening_socket} = Socket.UDP.open
    ip_port = Utils.ipstr_to_tupel(socket)

    :ok = send_syn(listening_socket, ip_port)
    run({listening_socket, ip_port, info_hash, node_id}, 1)
  end

  @doc ~S"""
  This function sends a uTP st_syn packet to a peer.

  """
  def send_syn(listening_socket, ip_port) do
    syn_packet = %UTP{type: :st_syn, seq_nr: @seq_nr, conn_id: @conn_id_recv}
    Socket.Datagram.send(listening_socket, UTP.encode(syn_packet), ip_port)
  end

  def run(peer_info, n) do
    if n == Utils.cfg(:number_of_packets, :handshake) do
      exit(:handshake_acceptor_finish)
    end

    {listening_socket, ip_port, _infohash, node_id} = peer_info

    case receive_packet(listening_socket) do
      {:ok, {packet, _ip_port}} ->
        decoded_utp_packet = UTP.decode(packet)
        response_id = save_utp_packet(decoded_utp_packet, node_id)
        handle_packet(decoded_utp_packet, peer_info, n, response_id)
      {:error, reason} ->
        Logger.info "#{@module} [#{inspect ip_port}] #{inspect(reason)} (#{n})"
        unless n == 1 do
          run(peer_info, n+1)
        end

    end
  end

  def receive_packet(listening_socket) do
    Socket.Datagram.recv(listening_socket, 0, [timeout: Utils.cfg(:recv_timeout, :handshake)])
  end

  def save_utp_packet(utp, node_id) do
    Logger.info inspect(utp)

    response = %DB.UTPResponse{
      ml_dht_nodes_id: node_id,
      size:            utp.size,
      type:            Atom.to_string(utp.type),
      version:         utp.version,
      extension:       utp.extension,
      conn_id:         utp.conn_id,
      ts_ms:           utp.ts_ms,
      ts_diff_ms:      utp.ts_diff_ms,
      wnd_size:        utp.wnd_size,
      seq_nr:          utp.seq_nr,
      ack_nr:          utp.ack_nr
    }
    entry = DB.Repo.insert(response)
    Logger.info "#{inspect entry}"
    Logger.info "#{entry.ml_dht_nodes_id}"
    entry.ml_dht_nodes_id
  end


  @doc ~S"""
  This function handles the first acknowledgement from the peer. It
  sends the BitTorrent handshake to the peer.

  """
  def handle_packet(%UTP{type: :st_state, ack_nr: @seq_nr, payload: ""},
                    peer_info, n, _id) do
    {listening_socket, ip_port, info_hash, _node_id} = peer_info
    info_hash = Utils.hex_to_str(info_hash)

    bt_handshake = Wire.encode(
      type:       :handshake,
      extensions: Utils.cfg(:extensions, :handshake),
      info_hash:  info_hash,
      peer_id:    Utils.cfg(:node_id)
    )

    Logger.info "#{@module} [inspect ip_port] send BitTorrent handshake via uTP"
    packet = UTP.encode %UTP{type: :st_data, conn_id: @conn_id_send,
                             seq_nr: @seq_nr+1, payload: bt_handshake}
    Socket.Datagram.send(listening_socket, packet, ip_port)
    run(peer_info, n+1)
  end

  def handle_packet(%UTP{type: :st_fin}, _peer_info, _n, _id), do: nil

  def handle_packet(%UTP{type: :st_data, ack_nr: @seq_nr+1, payload: payload},
                    peer_info, n, id) do
    decoded_bt_msg = Wire.decode_messages(payload)
    Logger.info "#{inspect(decoded_bt_msg, limit: 10000)}"
    elem(decoded_bt_msg, 0)
    |> extract_bt_packet(id)

    run(peer_info, n+1)
  end

  def handle_packet(_utp, peer_info, n, _id) do
    Logger.info "ignore"
    run(peer_info, n+1)
  end


  def extract_bt_packet([], _id), do: nil
  def extract_bt_packet([bt_packet | rest], id) do
    save_bt_packet(bt_packet, id)
    extract_bt_packet(rest, id)
  end

  @doc ~S"""
  This function checks if a peer with a particular extension binary
  supports Distributed Hash Table (DHT).

  """
  def supports_dht?(<<_, _, _, _, _, _, _, ext_byte>>) do
    <<_::1, _::1, _::1, _::1, _::1, _::1, _::1, dht::1>> = <<ext_byte>>
    if dht == 1, do: true, else: false
  end

  @doc ~S"""
  This function checks if a peer with a particular extension binary
  supports Allowed Fast Extension (AFE).

  """
  def supports_afe?(<<_, _, _, _, _, _, _, ext_byte>>) do
    <<_::1, _::1, _::1, _::1, _::1, afe::1, _::1, _::1>> = <<ext_byte>>
    if afe == 1, do: true, else: false
  end

  @doc ~S"""
  This function checks if a peer with a particular extension binary
  supports LibTorrent Extension Protocol (LTEP).

  """
  def supports_ltep?(<<_, _, _, _, _, ext_byte, _, _>>) do
    <<_::1, _::1, _::1, ltep::1, _::1, _::1, _::1, _::1>> = <<ext_byte>>
    if ltep == 1, do: true, else: false
  end

  @doc ~S"""
  This function checks if a peer with a particular extension binary
  supports Azureus Message Protocol (AZMP).

  """
  def supports_azmp?(<<ext_byte, _, _, _, _, _, _, _>>) do
    <<azmp::1, _::1, _::1, _::1, _::1, _::1, _::1, _::1>> = <<ext_byte>>
    if azmp == 1, do: true, else: false
  end


  @doc ~S"""
  This function saves important BitTorrent messages like handshake and
  LTEP messages to the database.

  """
  def save_bt_packet([type: :handshake, extension: extension, info_hash: _info,
                      peer_id: _peer_id], id) do
    entry = %DB.BtSupportedExtensions{
      ml_dht_nodes_id: id,
      supports_dht:    supports_dht?(extension),
      supports_afe:    supports_afe?(extension),
      supports_ltep:   supports_ltep?(extension),
      supports_azmp:   supports_azmp?(extension),
      extension_bytes: extension
    }

    case DB.BtSupportedExtensions.validate(entry) do
      %{ml_dht_nodes_id: [{:ok}]} ->
        DB.Repo.insert(entry)
      %{ml_dht_nodes_id: [error: message]} ->
        Logger.info("#{@module} Could not add handshake: #{message}")
    end
  end

  def save_bt_packet([type: :ltep, ext_msg_id: 0, msg: msg], id) do
    entry = %DB.BtLTEPMessages{
      ml_dht_nodes_id: id,
      complete_ago:  msg["complete_ago"],
      e:             msg["e"],
      ipv6:          Utils.ipv6_to_ipstr(msg["ipv6"]),
      metadata_size: msg["metadata_size"],
      reqq:          msg["reqq"],
      version:       msg["v"],
      messages:      inspect msg["m"]
    }

    case DB.BtLTEPMessages.validate(entry) do
      %{ml_dht_nodes_id: [{:ok}]} ->
        DB.Repo.insert(entry)
      %{ml_dht_nodes_id: [error: message]} ->
        Logger.info("#{@module} Could not add ltep message: #{message}")
    end
  end

  def save_bt_packet(_bt_packet, _id), do: nil

end
