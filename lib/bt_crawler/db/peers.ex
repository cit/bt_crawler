defmodule BtCrawler.DB.Peers do
	use Ecto.Model

  schema "peers" do
    # field :id, :integer, default: 0
    field :peer,      :string
    field :info_hash, :string
    field :requested, :integer
  end
end
