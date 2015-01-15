defmodule BtCrawler.DB.Repo.Migrations.CreateBtLtepMessages do
  use Ecto.Migration

  def up do
    """
    CREATE TABLE bt_ltep_messages (
      id               SERIAL NOT NULL UNIQUE
      ,ml_dht_nodes_id INTEGER REFERENCES ml_dht_nodes(id) NOT NULL UNIQUE
      ,complete_ago    INTEGER
      ,e               INTEGER
      ,ipv6            CHARACTER VARYING(39)
      ,metadata_size   INTEGER
      ,reqq            INTEGER
      ,version         CHARACTER VARYING(100)
      ,messages        CHARACTER VARYING(512)
    );
    """
  end

  def down do
    "DROP TABLE bt_ltep_messages"
  end
end
