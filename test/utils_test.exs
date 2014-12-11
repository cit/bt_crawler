defmodule UtilsTest do
 	use ExUnit.Case

  test "hex_to_str works" do
    str = Utils.hex_to_str("54686973206973206120746573742e")
    assert str == "This is a test."
  end
end
