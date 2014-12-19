require Logger

defmodule BtCrawler.CLI do


  def main(_argv) do
    Logger.info "BitTorrent Crawler started"
    Logger.warn "warnung"

    ## start with the boostraping node from our config
    # pid1 = spawn_monitor(BtCrawler.PeerHarvester, :init, [Utils.cfg(:bootstrap_node)])
    # pid2 = spawn_monitor(BtCrawler.PeerHarvester, :init, [Utils.cfg(:bootstrap_node)])
    # receive do
    #   {:DOWN, ref, :process, pid, reason} ->
    #     Logger.error "#{inspect pid} is down: #{reason}"
    #     # main(_argv)
    # end


  end




end
