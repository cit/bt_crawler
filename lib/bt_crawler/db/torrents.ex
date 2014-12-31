defmodule BtCrawler.DB.Torrents do
  use Ecto.Model

  schema "torrents" do
    field :piratebay_id,  :integer
    field :name,          :string
    field :size,          :integer
    field :seeders,       :integer
    field :leechers,      :integer
    field :info_hash,     :string
    field :requested,     :boolean, default: false
    field :requested_at,  :datetime
  end

end
