defmodule BtCrawler do
  use Application

  require Logger

  def start(_type, _args) do
    Logger.info "#{__MODULE__} start"

    ## start main supervisor
    {:ok, sup} = BtCrawler.Supervisor.start_link()
  end

end
