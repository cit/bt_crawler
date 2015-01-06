defmodule BtCrawler.DB.Repo.Migrations.CreateMlDhtResponses do
  use Ecto.Migration

  def up do
    """
    CREATE TABLE ml_dht_responses (
      id                 SERIAL NOT NULL UNIQUE
      ,added_at          TIMESTAMP DEFAULT NOW()
      ,payload_size      INTEGER NOT NULL
      ,nodes             INTEGER NOT NULL
      ,values            INTEGER
      ,version           CHARACTER VARYING(2)
      ,ml_dht_nodes_id   INTEGER REFERENCES ml_dht_nodes(id) NOT NULL
    );
    """
  end

  def down do
    "DROP TABLE ml_dht_responses"
  end
end
