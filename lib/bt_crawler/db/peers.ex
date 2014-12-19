defmodule BtCrawler.DB.Peers do
  use Ecto.Model

  schema "peers" do
    field :peer,      :string
    field :info_hash, :string
    field :requested, :integer
  end

  validate peers,
    peer: unique()

  @doc """
  This function checks if an entry is unique. It counts the number of
  entries with a specific peer string. It returns {:ok} if it is
  unique, or {:error} if it a peer already exists.
  """
  def unique(_opts, value) do
    from(p in BtCrawler.DB.Peers,
         where: p.peer == ^value,
         select: count(p.id))
    |> BtCrawler.DB.Repo.one
    |> case do
         0 -> {:ok}
         _ -> {:error, "peer already exists"}
       end
  end

end
