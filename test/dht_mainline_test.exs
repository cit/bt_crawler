defmodule BtCrawlerDHTMainlineTest do
  use ExUnit.Case

  alias BtCrawler.DHT.Mainline

  ## extract values

  test "extract_value works" do
    result = Mainline.extract_values([<<5, 13, 17, 155, 60, 197>>])
    assert result == [{"5.13.17.155", 15557}]
  end

  ## extract nodes

  test "extract nodes works" do
    byte_str = <<250, 250, 250, 250, 250, 250, 250, 250, 250, 250,
                 250, 250, 250, 250, 250, 250, 250, 250, 250, 250,
                 46, 19, 115, 68, 186, 6>>
    result = Mainline.extract_nodes(byte_str)
   assert result == [{"46.19.115.68", 47622}]
  end

  test "compact format for IPv4 works" do
    ip = Mainline.compact_format(<<46, 19, 115, 68, 186, 6>>)
    assert ip == {"46.19.115.68", 47622}
  end

  ## PING Query

  test "Mainline DHT query ping works" do
    str = Mainline.ping "aaaaaaaaaaaaaaaaaaaa"
    assert str == "d1:ad2:id20:aaaaaaaaaaaaaaaaaaaae1:q4:ping1:t2:aa1:y1:qe"
  end

  ## FIND_NODE Query

  test "Mainline DHT query find_node works" do
    str = Mainline.find_node "aaaaaaaaaaaaaaaaaaaa", "bbbbbbbbbbbbbbbbbbbb"
    assert str == "d1:ad2:id20:aaaaaaaaaaaaaaaaaaaa6:target20:bbbbbbbbbbbbbbbbbbbbe1:q9:find_node1:t2:aa1:y1:qe"
  end

  ## GET_PEERS Query

  test "Mainline DHT query get_peers works" do
    str = Mainline.get_peers "aaaaaaaaaaaaaaaaaaaa", "bbbbbbbbbbbbbbbbbbbb"
    assert str == "d1:ad2:id20:aaaaaaaaaaaaaaaaaaaa9:info_hash20:bbbbbbbbbbbbbbbbbbbbe1:q9:get_peers1:t2:aa1:y1:qe"
  end

  test "Mainline DHT query get_peers with want works" do
    str = Mainline.get_peers "aaaaaaaaaaaaaaaaaaaa", "bbbbbbbbbbbbbbbbbbbb", "n4"
    assert str == "d1:ad2:id20:aaaaaaaaaaaaaaaaaaaa9:info_hash20:bbbbbbbbbbbbbbbbbbbb4:want2:n4e1:q9:get_peers1:t2:aa1:y1:qe"
  end

  test "Mainline DHT query get_peers with scrape works" do
    str = Mainline.get_peers "aaaaaaaaaaaaaaaaaaaa", "bbbbbbbbbbbbbbbbbbbb", :scrape
    assert str == "d1:ad2:id20:aaaaaaaaaaaaaaaaaaaa9:info_hash20:bbbbbbbbbbbbbbbbbbbb6:scrapei1ee1:q9:get_peers1:t2:aa1:y1:qe"
  end

  test "Mainline DHT query get_peers with want and scrape works" do
    str = Mainline.get_peers "aaaaaaaaaaaaaaaaaaaa", "bbbbbbbbbbbbbbbbbbbb", "n6", :scrape
    assert str == "d1:ad2:id20:aaaaaaaaaaaaaaaaaaaa9:info_hash20:bbbbbbbbbbbbbbbbbbbb6:scrapei1e4:want2:n6e1:q9:get_peers1:t2:aa1:y1:qe"
  end


end
