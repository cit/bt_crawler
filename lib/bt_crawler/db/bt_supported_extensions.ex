defmodule BtCrawler.DB.BtSupportedExtensions do
	use Ecto.Model

  schema "bt_supported_extensions" do
    belongs_to :ml_dht_nodes,    BtCrawler.DB.MlDHTNodes
    field      :supports_dht,    :boolean, default: false
    field      :supports_afe,    :boolean, default: false
    field      :supports_ltep,   :boolean, default: false
    field      :supports_azmp,   :boolean, default: false
    field      :extension_bytes, :string
  end

  validate bt_supported_extensions,
    ml_dht_nodes_id: unique()

  @doc """
  This function checks if an entry is unique. It counts the number of
  entries with a specific peer string. It returns {:ok} if it is
  unique, or {:error} if it a peer already exists.
  """
  def unique(_opts, value) do
    from(p in BtCrawler.DB.BtSupportedExtensions,
         where: p.ml_dht_nodes_id == ^value,
         select: count(p.id))
    |> BtCrawler.DB.Repo.one
    |> case do
         0 -> {:ok}
         _ -> {:error, "handshake already exists"}
       end
  end
end
