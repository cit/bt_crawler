defmodule BtCrawler.Supervisor do
  use Supervisor

  require Logger

  def start_link do
    Logger.info "#{__MODULE__} start_link"
    {:ok, _pid} = Supervisor.start_link(__MODULE__, [])
  end

  def init(_args) do
    Logger.info "#{__MODULE__} init"

    tree = [
       ## Database (ecto)
       worker(BtCrawler.DB.Repo, []),

       ## Supervisor for the Peer Harvester
       supervisor(BtCrawler.PeerHarvesterSupervisor, []),

       ## Supervisor for the Handshake Acceptor
       supervisor(BtCrawler.HandshakeAcceptorSupervisor, [])
    ]

    supervise(tree, strategy: :one_for_one)
  end

end
