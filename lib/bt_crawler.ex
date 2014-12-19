defmodule BtCrawler do
  use Application

  require Logger



  def start(_type, _args) do
    Logger.info "#{__MODULE__} start"

    {:ok, sup} = BtCrawler.Supervisor.start_link()

    # BtCrawler.HarvesterSupervisor.foo()


    # endless_loop()
    # GenServer.call(:harvester1, :harvest)
    # GenServer.cast(:foo2, :harvest)
    # BtCrawler.PeerHarvester.harvest()

    # IO.puts "#{msg}"

    # {:ok, sup} = KV.Bucket.Supervisor.start_link
    # BtCrawler.HarvesterSupervisor.start_bucket(5)
    # import Supervisor.Spec, warn: false

    # ## tree defines worker and child superviros to be supervised
    # tree = [
    #    ## Database (ecto)
    #    worker(BtCrawler.DB.Repo, [[name: @manager_name]]),

    #    ## Supervisor for the Peer Harvester
    #    supervisor(BtCrawler.HarvesterSupervisor, [[name: @bucket_sup_name]])
    # ]

    # opts = [name: Simple.Sup, strategy: :one_for_one]
    # # Supervisor.start_link(tree, opts)
    # supervise(tree, strategy: :one_for_one, max_restarts: 10)
  end

  def foo do
    GenServer.cast(:harvester1, :start)
  end




end
