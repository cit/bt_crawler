defmodule BtCrawler.DHT.Mainline do
  require Bencodex
  require Logger

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

  def parse(%{"y" => status, "e" => error_msg}) when status == "e" do
    Logger.error error_msg
    []
  end

  def parse(%{"y" => status, "r" => param_map, "v" => version}) when status == "r" do
    Logger.info "version: #{String.slice(version, 0..1)}"
    parse(%{"y" => "r", "r" => param_map})
  end

  def parse(%{"y" => status, "r" => param_map}) when status == "r" do
    Logger.info(inspect extract_values param_map["values"])
    extract_nodes param_map["nodes"]
  end



  @doc """
  This function extracts the Ipv4 address from a 'get_peers' response
  which are sharing the given infohash. (values)

    ## Example
    iex> extract_values([<<5, 13, 17, 155, 60, 197>>])
    [{"5.13.17.155", 15557}]
  """
  def extract_values(nil), do: []

  def extract_values(nodes), do: extract_values(nodes, [])

  def extract_values([], result), do: result

  def extract_values([addr | tail], result) do
    extract_values(tail, result ++ [compact_format(addr)])
  end



  @doc """
  This function takes the nodes element and extracts all the IPv4
  nodes and returns it as a list.

    ## Excample
    iex> extract_nodes(<<250, 250, ...>>)
    [{"46.19.115.68", 47622}]
  """
  def extract_nodes(nil), do: []

  def extract_nodes(nodes), do: extract_nodes(nodes, [])

  def extract_nodes(<<>>, result), do: result

  def extract_nodes(<<_id :: binary-size(20), addr :: binary-size(6),
                    tail :: binary>>, result) do
    extract_nodes(tail, result ++ [compact_format(addr)])
  end


  @doc """
  This function takes a byte string which is encoded in compact format
  and extracts the socket address (IPv4, port) and returns it.

  ## Example

    iex> compact_format(<<46, 19, 115, 68, 186, 6>>)
    {"46.19.115.68", 47622}
  """
  def compact_format(<<ipv4 :: binary-size(4), port :: size(16) >>) do
    << oct1 :: size(8), oct2 :: size(8),
       oct3 :: size(8), oct4 :: size(8) >> = ipv4
    {"#{oct1}.#{oct2}.#{oct3}.#{oct4}", port}
  end

end
