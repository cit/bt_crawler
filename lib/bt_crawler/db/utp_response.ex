defmodule BtCrawler.DB.UTPResponse do
  use Ecto.Model

  schema "utp_response" do
    belongs_to :ml_dht_nodes, BtCrawler.DB.MlDHTnodes
    field :received_at,       :datetime
    field :size,              :integer
    field :type,              :string
    field :version,           :integer
    field :extension,         :integer
    field :conn_id,           :integer
    field :ts_ms,             :integer
    field :ts_diff_ms,        :integer
    field :wnd_size,          :integer
    field :seq_nr,            :integer
    field :ack_nr,            :integer
  end

end
