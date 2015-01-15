defmodule BtCrawler.DB.BtLTEPMessages do
  use Ecto.Model

  schema "bt_ltep_messages" do
    belongs_to :ml_dht_nodes,    BtCrawler.DB.MlDHTNodes
    field      :complete_ago,    :integer
    field      :e,               :integer
    field      :ipv6,            :string
    field      :metadata_size,   :integer
    field      :reqq,            :integer
    field      :version,         :string
    field      :messages,        :string
  end

  validate bt_supported_extensions,
  ml_dht_nodes_id: unique()

  @doc """
  This function checks if an entry is unique. It counts the number of
  entries with a specific peer string. It returns {:ok} if it is
  unique, or {:error} if it a peer already exists.
  """
  def unique(_opts, value) do
    from(p in BtCrawler.DB.BtLTEPMessages,
         where: p.ml_dht_nodes_id == ^value,
         select: count(p.id))
    |> BtCrawler.DB.Repo.one
    |> case do
         0 -> {:ok}
         _ -> {:error, "LTEP message already exists"}
       end
  end

end
