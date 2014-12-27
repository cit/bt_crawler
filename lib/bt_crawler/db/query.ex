defmodule BtCrawler.DB.Query do
  import Ecto.Query
  alias  Ecto.Adapters.Postgres, as: Postgres

  @doc """
  This function creates a custom SQL query and executes it on the
  PostgreSQL server. It firsts searches for an not requested peer and
  updates it immediately. This should guarantee that multiple process
  don not get the same peer.
  """
  def get_not_requested_peer do
    sql_query = """
      UPDATE ml_dht_nodes p
      SET    requested=true, requested_at=NOW()
      FROM (
        SELECT socket
        FROM   ml_dht_nodes
        WHERE  requested=false
        ORDER  BY info_hash DESC
        LIMIT  1
        FOR    UPDATE
     ) sub
     WHERE p.socket = sub.socket
     RETURNING p.socket;
    """

    result = Postgres.query(BtCrawler.DB.Repo, sql_query, [])
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


end
