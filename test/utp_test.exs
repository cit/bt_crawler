defmodule BtCrawlerUTPTest do
  use ExUnit.Case

  alias BtCrawler.UTP

  test "packet with type :st_data" do
    packet = %UTP{type: :st_data}
    assert << 1, _rest :: binary >> = UTP.encode(packet)
  end

  test "packet with type :st_syn" do
    packet = %UTP{type: :st_syn}
    assert << 65, _rest :: binary >> = UTP.encode(packet)
  end

  test "packet with type :st_fin" do
    packet = %UTP{type: :st_fin}
    assert << 17, _rest :: binary >> = UTP.encode(packet)
  end

  test "packet with type :st_state" do
    packet = %UTP{type: :st_state}
    assert << 33, _rest :: binary >> = UTP.encode(packet)
  end

  test "packet with type :st_reset" do
    packet = %UTP{type: :st_reset}
    assert << 49, _rest :: binary >> = UTP.encode(packet)
  end

  test "decode packet" do
    bin = <<1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>
    assert UTP.decode(bin) == %UTP{type: :st_data, version: 1, size: 20}
  end
end
