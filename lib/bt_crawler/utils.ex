defmodule BtCrawler.Utils do

  def cfg(name) do
    all_env = Application.get_all_env(:crawler)
    all_env[name]
  end

  def cfg(name, category) do
    all_env = Application.get_all_env(category)
    all_env[name]
  end

  def gen_cfg_func(category) do
    fn name ->
      all_env = Application.get_all_env(category)
      all_env[name]
    end
  end

  def ipv6_to_ipstr(binary), do: ipv6_to_ipstr(binary, "")
  def ipv6_to_ipstr(<<>>, str), do: String.slice(str, 0, String.length(str)-1)
  def ipv6_to_ipstr(binary, str) do
    <<oct::16, rest::binary>> = binary

    new_str = str <> Integer.to_string(oct, 16)
    |> String.downcase

    ipv6_to_ipstr(rest, new_str <> ":")
  end


  @doc ~S"""
  This function converts a tuple like tupel {"192.168.1.1", 1337} to a
  binary

    ## Example

    iex> tupel_to_ipstr({"192.168.1.1", 1337})
    "192.168.1.1:1337"

  """
  def tupel_to_ipstr({ipv4_addr, port}) do
    "#{ipv4_addr}:#{port}"
  end

  @doc ~S"""
  This function converts an ipv4 binary to an tupel.

    ## Example

    iex> ipstr_to_tupel("192.168.1.1:1337")
    {"192.168.1.1", 1337}

  """
  def ipstr_to_tupel(ipstr) do
    [ipv4_address, port] = String.split ipstr, ":"
    {port, _} = Integer.parse(port)
    {ipv4_address, port}
  end


  @doc ~S"""
  This function converts binary encoded in hex to a str.

    ## Example

    iex> hex_to_str("This is a test.")
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
