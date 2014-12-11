defmodule Utils do

  def cfg(name) do
    all_env = Application.get_all_env(:crawler)
    all_env[name]
  end

  @doc """
  This function converts binary encoded in hex to a str.

  ## Example

      ie> hex_to_str("This is a test.")
      "54686973206973206120746573742e"

  """
  def hex_to_str(hex_str) when is_binary(hex_str) do
    :binary.bin_to_list(hex_str)
    |> hex_to_str
    |> IO.iodata_to_binary
  end

  def hex_to_str([]), do: []

    def hex_to_str([x, y | tail]) do
      [to_int(x) * 16 + to_int(y) | hex_to_str(tail)]
    end

    defp to_int(c) when ?0 <= c and c <= ?9 do
      c - ?0
    end

    defp to_int(c) when ?A <= c and c <= ?F do
      c - ?A + 10
    end

    defp to_int(c) when ?a <= c and c <= ?f do
      c - ?a + 10
    end



end
