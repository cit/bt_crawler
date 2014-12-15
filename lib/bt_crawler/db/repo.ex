require Logger

defmodule BtCrawler.DB.Repo do
  use Ecto.Repo, adapter: Ecto.Adapters.Postgres

  def conf do
    parse_url "ecto://bt_crawler:bt_crawler@localhost/bt_crawler"
  end

  def priv do
    app_dir(:bt_crawler, "priv/repo")
  end
end
