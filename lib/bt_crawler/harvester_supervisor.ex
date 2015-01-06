defmodule BtCrawler.HarvesterSupervisor do
  use Supervisor

  require Logger

  alias BtCrawler.DB
  alias BtCrawler.PeerHarvester

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def start_tasks do
    func = fn ->
      PeerHarvester.start(DB.Query.get_not_requested_torrent())
    end

    ## generate a tree of n workers to harvest peers from DHT
    tree = Enum.map(1..5, fn(n) -> worker(Task, [func], [id: "cnt#{n}"]) end)

    Supervisor.start_link(tree, strategy: :one_for_one, name: __MODULE__)
  end

  def init(_args) do
    Logger.info "#{__MODULE__} init"

    supervise([], strategy: :one_for_one, name: __MODULE__)
  end



end
