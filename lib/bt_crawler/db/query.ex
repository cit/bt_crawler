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
      UPDATE peers p
      SET    requested=1
      FROM (
        SELECT peer
        FROM   peers
        WHERE  requested=0
        LIMIT  1
        FOR    UPDATE
     ) sub
     WHERE p.peer = sub.peer
     RETURNING p.peer;
    """

    result = Postgres.query(BtCrawler.DB.Repo, sql_query, [])
    %Postgrex.Result{rows: [rows]} = result
    elem(rows, 0)
  end

  @doc """
  This function gets a socket string and returns the complete row from
  the tables peers.
  """
  def get_peer(sock) when is_binary(sock) do
    query = from p in BtCrawler.DB.Peers,
    where: p.peer == ^sock,
    limit: 1,
    select: p
    BtCrawler.DB.Repo.all(query)
  end

end
