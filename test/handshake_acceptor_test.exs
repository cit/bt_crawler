defmodule BtCrawlerHandshakeAcceptorTest do
  use ExUnit.Case

  alias BtCrawler.HandshakeAcceptor

  test "if supports_dht?/1 returns true " do
    assert HandshakeAcceptor.supports_dht?(<<0, 0, 0, 0, 0, 0, 0, 1>>) == true
  end

  test "if supports_dht?/1 returns false " do
    assert HandshakeAcceptor.supports_dht?(<<0, 0, 0, 0, 0, 0, 0, 0>>) == false
  end


  test "if supports_afe/1 returns true " do
    assert HandshakeAcceptor.supports_afe?(<<0, 0, 0, 0, 0, 0, 0, 4>>) == true
  end

  test "if supports_afe/1 returns false " do
    assert HandshakeAcceptor.supports_afe?(<<0, 0, 0, 0, 0, 0, 0, 0>>) == false
  end


  test "if supports_ltep?/1 returns true " do
    assert HandshakeAcceptor.supports_ltep?(<<0, 0, 0, 0, 0, 16, 0, 0>>) == true
  end

  test "if supports_ltep?/1 returns false " do
    assert HandshakeAcceptor.supports_ltep?(<<0, 0, 0, 0, 0, 0, 0, 0>>) == false
  end


  test "if supports_azmp?/1 returns true " do
    assert HandshakeAcceptor.supports_azmp?(<<128, 0, 0, 0, 0, 0, 0, 0>>) == true
  end

  test "if supports_azmp?/1 returns false " do
    assert HandshakeAcceptor.supports_azmp?(<<0, 0, 0, 0, 0, 0, 0, 0>>) == false
  end

end
