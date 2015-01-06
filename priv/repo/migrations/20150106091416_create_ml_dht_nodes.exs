defmodule BtCrawler.DB.Repo.Migrations.CreateMlDhtNodes do
  use Ecto.Migration

  def up do
    """
    CREATE TABLE ml_dht_nodes (
      id                 SERIAL NOT NULL UNIQUE
      ,added_at          TIMESTAMP NOT NULL DEFAULT NOW()
      ,socket            CHARACTER VARYING(21) NOT NULL UNIQUE
      ,info_hash         CHARACTER VARYING(40)
      ,requested         BOOLEAN NOT NULL
      ,requested_at      TIMESTAMP
      ,send_handshake    BOOLEAN NOT NULL
      ,send_handshake_at TIMESTAMP
      ,torrent_id        INTEGER REFERENCES torrents(id)
    );
    """
  end

  def down do
    "DROP TABLE ml_dht_nodes"
  end
end
