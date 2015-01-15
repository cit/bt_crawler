defmodule BtCrawler.DB.Repo.Migrations.CreateBtSupportedExtensions do
  use Ecto.Migration

  def up do
    """
    CREATE TABLE bt_supported_extensions (
      id               SERIAL NOT NULL UNIQUE
      ,ml_dht_nodes_id INTEGER REFERENCES ml_dht_nodes(id) NOT NULL UNIQUE
      ,supports_dht    BOOLEAN NOT NULL DEFAULT FALSE
      ,supports_afe    BOOLEAN NOT NULL DEFAULT FALSE
      ,supports_ltep   BOOLEAN NOT NULL DEFAULT FALSE
      ,supports_azmp   BOOLEAN NOT NULL DEFAULT FALSE
      ,extension_bytes BYTEA NOT NULL
    );
    """
  end

  def down do
    "DROP TABLE bt_supported_extensions"
  end
end
