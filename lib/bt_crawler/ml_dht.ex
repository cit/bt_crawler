require Bencodex

defmodule BtCrawler.MlDHT do

  defp dht_packet(command, options) do
    Bencodex.encode %{
                "t" => "aa",
                "y" => "q",
                "q" => command,
                "a" => options
            }
  end

  @doc ~S"""
  This function returns a bencoded Mainline DHT ping query. It needs a
  20 bytes node id as an argument.

  ## Example
  iex> BtCrawler.MlDHT.ping "aaaaaaaaaaaaaaaaaaaa"
  """
  def ping(id) when byte_size(id) == 20 do
    dht_packet "ping", %{"id" => id}
  end


  @doc ~S"""
  This function returns a bencoded Mainline DHT find_node query. It
  needs a 20 bytes node id and a 20 bytes target id as an argument.

  ## Example
  iex> BtCrawler.MlDHT.ping "aaaaaaaaaaaaaaaaaaaa", "bbbbbbbbbbbbbbbbbbbb"
  """
  def find_node(id, target) when byte_size(id) == 20 do
    dht_packet "find_node", %{"id" => id, "target" => target}
  end


  defp get_peers_dict(id, info_hash) do
    %{"id" => id, "info_hash" => info_hash}
  end

  @doc ~S"""
  This function returns a bencoded Mainline DHT get_peers query. It
  needs a 20 bytes node id and a 20 bytes info_has as an
  argument. Optional arguments are 'want' and :scrape.

  ## Example
  iex> BtCrawler.MlDHT.ping "aaaaaaaaaaaaaaaaaaaa", "bbbbbbbbbbbbbbbbbbbb"
  """
  def get_peers(id, info_hash) do
    dht_packet "get_peers", get_peers_dict(id, info_hash)
  end

  def get_peers(id, info_hash, want) when is_binary(want) do
    dict = get_peers_dict(id, info_hash)
    dht_packet "get_peers", Dict.put_new(dict, "want", want)
  end

  def get_peers(id, info_hash, :scrape) when is_atom(:scrape) do
    dict = get_peers_dict(id, info_hash)
    dht_packet "get_peers", Dict.put_new(dict, "scrape", 1)
  end

  def get_peers(id, info_hash, want, :scrape) do
    dht_packet "get_peers", get_peers_dict(id, info_hash)
    |> Dict.put_new("scrape", 1)
    |> Dict.put_new("want", want)
  end


  @doc ~S"""
  TODO
  """
  def parse(payload) when is_binary(payload) do
    try do
      Bencodex.decode(payload) |> parse
    rescue
      e in RuntimeError -> e
    end
  end

  def parse(payload) when is_list(payload) do

  end

  def parse(map) when is_map(map) do
    IO.puts inspect(extract_nodes map["r"]["nodes"], [])
  end


  @doc """
  This function takes the nodes element and extracts all the IPv4
  nodes and returns it as a list.
  """
  def extract_nodes(<<>>, result), do: result

  def extract_nodes(<<_id :: binary-size(20), ip :: binary-size(4),
                    port :: size(16), _rest :: binary >>, result) do
    ## extract the IPv4 address
    << oct1 :: size(8), oct2 :: size(8), oct3 :: size(8), oct4 :: size(8) >> = ip

    result = result ++ ["#{oct1}.#{oct2}.#{oct3}.#{oct4}:#{port}"]
    extract_nodes _rest, result
  end



end
