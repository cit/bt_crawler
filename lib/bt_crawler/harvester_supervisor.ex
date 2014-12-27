defmodule BtCrawler.HarvesterSupervisor do
  use Supervisor

  require Logger

  alias BtCrawler.DB

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(_args) do
    Logger.info "#{__MODULE__} init"

    harvester = fn ->
      BtCrawler.PeerHarvester.start(DB.Query.get_not_requested_torrent())
    end
    ## generate a tree of n workers to harvest peers from DHT
    tree = Enum.map(1..5,
      fn(n) -> worker(Task, [harvester],
                      [id: "cnt#{n}"]) end)

    supervise(tree, strategy: :one_for_one, name: __MODULE__)
  end



end
