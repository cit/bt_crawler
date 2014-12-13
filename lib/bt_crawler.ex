# defmodule BtCrawler do
# end

defmodule BtCrawler.App do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec
    tree = [worker(BtCrawler.DB.Repo, [])]
    opts = [name: Simple.Sup, strategy: :one_for_one]
    Supervisor.start_link(tree, opts)
  end
end
