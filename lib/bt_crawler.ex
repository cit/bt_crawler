defmodule BtCrawler do
  use Application

  require Logger

  def start(_type, _args) do
    Logger.info "#{__MODULE__} start"

    ## start main supervisor
    {:ok, _sup} = BtCrawler.Supervisor.start_link()
  end

  @doc ~S"""
  This function starts the peer harvester and the peer requester.

  """
  def start_crawler do
    BtCrawler.PeerHarvesterSupervisor.start_tasks
    BtCrawler.HandshakeAcceptorSupervisor.start_tasks
  end

end
