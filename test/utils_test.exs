defmodule UtilsTest do
 	use ExUnit.Case

  alias BtCrawler.Utils

  test "hex_to_str works" do
    str = Utils.hex_to_str("54686973206973206120746573742e")
    assert str == "This is a test."
  end

  test "tupel_to_ipstr works" do
    assert Utils.tupel_to_ipstr({"192.168.1.1", 1337}) == "192.168.1.1:1337"
  end

  test "ipstr_to_tupel" do
    assert Utils.ipstr_to_tupel("192.168.1.1:1337") == {"192.168.1.1", 1337}
  end

  test "if ipv6_to_ipstr/1 works correctly" do
    ipv6_addr = <<32, 2, 49, 149, 70, 78, 0, 0, 0, 0, 0, 0, 49, 149, 70, 78>>
    assert Utils.ipv6_to_ipstr(ipv6_addr) == "2002:3195:464e:0:0:0:3195:464e"
  end
end
