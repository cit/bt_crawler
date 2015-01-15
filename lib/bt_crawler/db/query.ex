defmodule BtCrawler.DB.Query do
  import Ecto.Query
  alias  Ecto.Adapters.Postgres, as: Postgres


  @doc """
  This functions returns socket and the info_hash of a peer, which has
  not received a handshake yet. This function returns a tupel, where
  the first element is the socket and the second is the info_hash.

    ## Example
    iex> BtCrawler.DB.Query.get_not_send_handshake_peer
    {"2.50.4.124:16972", "fcc0eec50445852e8de095e26f6c2959401979c4"}
  """
  def get_not_send_handshake_peer do
    sql_query = """
      UPDATE ml_dht_nodes p
      SET    send_handshake=true, send_handshake_at=NOW()
      FROM (
        SELECT socket
        FROM   ml_dht_nodes
        WHERE  send_handshake=false
        AND    info_hash != ''
        ORDER  BY requested_at DESC
        LIMIT  1
        FOR    UPDATE
     ) sub
     WHERE p.socket = sub.socket
     RETURNING p.socket, p.info_hash, p.id;
    """

    case Postgres.query(BtCrawler.DB.Repo, sql_query, []) do
      %Postgrex.Result{rows: []} ->
        nil
      %Postgrex.Result{rows: [rows]} ->
        rows
    end
  end


  def get_not_requested_torrent do
    sql_query = """
      UPDATE torrents t
      SET    requested=true, requested_at=NOW()
      FROM (
        SELECT info_hash
        FROM   torrents
        WHERE  requested=false
        ORDER  BY seeders DESC
        LIMIT  1
        FOR    UPDATE
     ) sub
     WHERE t.info_hash = sub.info_hash
     RETURNING t.info_hash;
    """

    result = Postgres.query(BtCrawler.DB.Repo, sql_query, [], [timeout: :infinity])
    %Postgrex.Result{rows: [rows]} = result
    elem(rows, 0)
  end


  @doc """
  This function creates a custom SQL query and executes it on the
  PostgreSQL server. It firsts searches for an not requested peer and
  updates it immediately. This should guarantee that multiple process
  don not get the same peer.
  """
  def get_not_requested_peer(info_hash, torrent_id) do
    sql_query = """
      UPDATE ml_dht_nodes p
      SET    requested=true, requested_at=NOW()
      FROM (
        SELECT socket
        FROM   ml_dht_nodes
        WHERE  requested=false
        AND  (info_hash=$1 OR info_hash='')
        and    torrent_id=$2
        ORDER  BY info_hash DESC
        LIMIT  1
        FOR    UPDATE
     ) sub
     WHERE p.socket = sub.socket
     RETURNING p.socket;
    """

    result = Postgres.query(BtCrawler.DB.Repo, sql_query, [info_hash, torrent_id])
    %Postgrex.Result{rows: [rows]} = result
    elem(rows, 0)
  end

  @doc """
  This function gets a socket string and returns the complete row from
  the tables peers.
  """
  def get_peer(socket) when is_binary(socket) do
    query = from p in BtCrawler.DB.MlDHTNodes,
    where: p.socket == ^socket,
    limit: 1,
    select: p
    BtCrawler.DB.Repo.all(query)
  end

  def get_id_from_socket(socket) do
    query = from p in BtCrawler.DB.MlDHTNodes,
    where: p.socket == ^socket,
    select: p.id
    BtCrawler.DB.Repo.all(query)
  end

  def get_id_from_torrent(info_hash) do
    query = from t in BtCrawler.DB.Torrents,
    where: t.info_hash == ^info_hash,
    select: t.id
    BtCrawler.DB.Repo.all(query)
  end

end
