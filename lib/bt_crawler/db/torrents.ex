defmodule BtCrawler.DB.Torrents do
  use Ecto.Model

  schema "torrents" do
    field :info_hash,     :string
    field :requested,     :boolean, default: false
    field :resquested_at, :datetime
  end

end
