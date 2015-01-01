 defmodule BtCrawler.DB.MlDHTResponses do
  use Ecto.Model

  schema "ml_dht_responses" do
    field      :added_at,     :datetime
    field      :payload_size, :integer
    field      :nodes,        :integer
    field      :values,       :integer
    field      :version,      :string
    belongs_to :ml_dht_nodes, BtCrawler.DB.MlDHTNodes
  end

end
