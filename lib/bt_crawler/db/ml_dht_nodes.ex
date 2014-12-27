defmodule BtCrawler.DB.MlDHTNodes do
  use Ecto.Model

  schema "ml_dht_nodes" do
    field      :added_at,          :datetime
    field      :socket,            :string
    field      :info_hash,         :string
    field      :requested,         :boolean, default: false
    field      :requested_at,      :datetime
    field      :send_handshake,    :boolean, default: false
    field      :send_handshake_at, :datetime
    belongs_to :torrent,           BtCrawler.DB.Torrents
  end

  validate ml_dht_nodes,
    socket: unique()

  @doc """
  This function checks if an entry is unique. It counts the number of
  entries with a specific peer string. It returns {:ok} if it is
  unique, or {:error} if it a peer already exists.
  """
  def unique(_opts, value) do
    from(p in BtCrawler.DB.MlDHTNodes,
         where: p.socket == ^value,
         select: count(p.id))
    |> BtCrawler.DB.Repo.one
    |> case do
         0 -> {:ok}
         _ -> {:error, "peer already exists"}
       end
  end

end
