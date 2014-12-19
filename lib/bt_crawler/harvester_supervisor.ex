defmodule BtCrawler.HarvesterSupervisor do
  use Supervisor

  require Logger

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(_args) do
    Logger.info "#{__MODULE__} init"

    ## generate a tree of n workers to harvest peers from DHT
    tree = Enum.map(1..5,
      fn(n) -> worker(Task, [fn -> BtCrawler.PeerHarvester.start() end],
                      [id: "cnt#{n}"]) end)

    supervise(tree, strategy: :one_for_one, name: __MODULE__)
  end



end
