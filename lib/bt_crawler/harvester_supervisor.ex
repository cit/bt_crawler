defmodule BtCrawler.HarvesterSupervisor do
  use Supervisor

  require Logger

  def start_link(opts \\ []) do
    Logger.info "#{__MODULE__} start_link"
    result = {:ok, pid} = Supervisor.start_link(__MODULE__, :ok, opts)
    start_workers(pid, 1)
    start_workers(pid, 2)
    result
  end

  def start_workers(pid, n) do
    Logger.info "#{__MODULE__} start_workers"

    Supervisor.start_child(pid, [n])
  end

  def restart_child(supervisor, child_id) do
    Logger.info "#{__MODULE__} restart"
  end

  def init(_args) do
    Logger.info "#{__MODULE__} init"
    ## tree defines worker and child superviros to be supervised
    tree = [
      ## Supervisor for the Peer Harvester
      # worker(BtCrawler.PeerHarvester, [Utils.cfg(:bootstrap_node)]),
      worker(BtCrawler.PeerHarvester, []),
      # worker(BtCrawler.PeerHarvester, [Utils.cfg(:bootstrap_node)])
    ]

    # tree = Enum.map(1..5, fn(n) -> worker(BtCrawler.PeerHarvester, [Utils.cfg(:bootstrap_node)], [id: "counter#{n}"]) end)

    Logger.info inspect tree

    # Supervisor.start_link(tree, [strategy: :simple_one_for_one, name: __MODULE__])
    supervise(tree, strategy: :simple_one_for_one, name: __MODULE__)


  end



end
