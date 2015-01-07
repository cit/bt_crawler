defmodule BtCrawler.HandshakeAcceptorSupervisor do
	use Supervisor

  require Logger

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def init(_args) do
    Logger.info "#{__MODULE__} init"

    func = fn ->
      BtCrawler.HandshakeAcceptor.listen(BtCrawler.Utils.cfg(:listening_port))
    end

    tree = [worker(Task, [func])]

    supervise(tree, strategy: :one_for_one, name: __MODULE__)
  end

end
