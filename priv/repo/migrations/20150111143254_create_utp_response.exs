defmodule BtCrawler.DB.Repo.Migrations.CreateUtpResponse do
  use Ecto.Migration

  def up do
    """
    CREATE TABLE utp_response (
      id               SERIAL NOT NULL UNIQUE
      ,ml_dht_nodes_id INTEGER REFERENCES ml_dht_nodes(id)
      ,received_at     TIMESTAMP NOT NULL DEFAULT NOW()
      ,size            INTEGER NOT NULL
      ,type            CHARACTER VARYING(10) NOT NULL
      ,version         SMALLINT NOT NULL
      ,extension       SMALLINT NOT NULL
      ,conn_id         INTEGER NOT NULL
      ,ts_ms           BIGINT NOT NULL
      ,ts_diff_ms      BIGINT NOT NULL
      ,wnd_size        BIGINT NOT NULL
      ,seq_nr          INTEGER NOT NULL
      ,ack_nr          INTEGER NOT NULL
    );
    """
  end

  def down do
    "DROP TABLE utp_response"
  end
end
