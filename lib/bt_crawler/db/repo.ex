defmodule BtCrawler.DB.Repo do
  require Logger

  alias BtCrawler.Utils

  use Ecto.Repo, adapter: Ecto.Adapters.Postgres

  def conf do
    cfg = Utils.gen_cfg_func(:db)

    parse_url gen_ecto_str(cfg.(:user), cfg.(:pass), cfg.(:host), cfg.(:database))
  end

  @doc """
  This function generates an ecto string which is in the following
  form: ecto://USERNAME:PASSWORD@HOST/DATABASE
  """
  def gen_ecto_str(user, pass, host, database) do
    "ecto://" <> user <> ":" <> pass <> "@" <> host <> "/" <> database
  end

  def priv do
    app_dir(:bt_crawler, Utils.cfg(:app_dir, :db))
  end
end
