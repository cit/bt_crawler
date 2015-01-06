defmodule BtCrawler.DB.Repo.Migrations.CreateTorrents do
  use Ecto.Migration

  def up do
    """
    CREATE TABLE torrents (
      id            SERIAL NOT NULL UNIQUE
      ,piratebay_id BIGINT NOT NULL UNIQUE
      ,name         TEXT NOT NULL
      ,size         BIGINT NOT NULL
      ,seeders      INTEGER
      ,leechers     INTEGER
      ,info_hash    CHARACTER VARYING(40) NOT NULL UNIQUE
      ,requested    BOOLEAN NOT NULL
      ,requested_at TIMESTAMP
    );
    """
  end

  def down do
    "DROP TABLE torrents"
  end
end
