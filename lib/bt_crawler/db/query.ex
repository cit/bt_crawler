defmodule BtCrawler.DB.Query do
  import Ecto.Query

  def get_not_requested_peer do
    query = from p in BtCrawler.DB.Peers,
    where: p.requested == 0,
    limit: 1,
    select: p
    BtCrawler.DB.Repo.all(query)
  end

  def get_peer(sock) when is_binary(sock) do
    query = from p in BtCrawler.DB.Peers,
    where: p.peer == ^sock,
    limit: 1,
    select: p
    BtCrawler.DB.Repo.all(query)
  end

end
