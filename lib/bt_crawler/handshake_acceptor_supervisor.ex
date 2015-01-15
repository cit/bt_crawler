defmodule BtCrawler.HandshakeAcceptorSupervisor do
	use Supervisor

  require Logger

  alias BtCrawler.DB
  alias BtCrawler.HandshakeAcceptor

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  def start_tasks do
    func = fn ->
      HandshakeAcceptor.listen(DB.Query.get_not_send_handshake_peer())
    end

    # tree = [worker(Task, [func])]
    tree = Enum.map(1..5, fn(n) -> worker(Task, [func], [id: "hndcnt#{n}"]) end)

    Supervisor.start_link(tree, strategy: :one_for_one, name: __MODULE__,
                          max_restarts: 10, max_seconds: 1)
  end

  def init(_args) do
    Logger.info "#{__MODULE__} init"

    supervise([], strategy: :one_for_one, name: __MODULE__)
  end

end
