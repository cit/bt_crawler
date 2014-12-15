defmodule BtCrawler.DB.Query do
  import Ecto.Query
  alias  Ecto.Adapters.Postgres, as: Postgres

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

  def get_peer(sock) when is_binary(sock) do
    query = from p in BtCrawler.DB.Peers,
    where: p.peer == ^sock,
    limit: 1,
    select: p
    BtCrawler.DB.Repo.all(query)
  end

end
