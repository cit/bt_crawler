defmodule BtCrawler.UTP do
  require Logger

  @types %{st_data: 0, st_fin: 1, st_state: 2, st_reset: 3, st_syn: 4}
  @foo {:st_data, :st_fin, :st_state, :st_reset, :st_syn}

  defstruct size: 0, type: :st_data, version: 1, extension: 0, conn_id: 0, ts_ms: 0,
            ts_diff_ms: 0, wnd_size: 0, seq_nr: 0, ack_nr: 0, payload: ""

  # def packet, do: packet(%{})

  def encode(utp) when is_map(utp) do
    << @types[utp.type]  || 0   :: size(4),
       utp.version       || 1   :: size(4),
       utp.extension     || 0   :: size(8),
       utp.conn_id       || 0   :: size(16),
       utp.ts_ms         || 0   :: size(32),
       utp.ts_diff_ms    || 0   :: size(32),
       utp.wnd_size      || 0   :: size(32),
       utp.seq_nr        || 0   :: size(16),
       utp.ack_nr        || 0   :: size(16),
       utp.payload       || ""  :: binary>>
  end

  def decode(packet) do
    <<type::4, version::4, extension::8, conn_id::16, ts_ms::32,
             ts_diff_ms::32, wnd_size::32, seq_nr::16, ack_nr::16,
             payload::binary>> = packet
    %BtCrawler.UTP{
      size:       byte_size(packet),
      type:       elem(@foo, type),
      version:    version,
      extension:  extension,
      conn_id:    conn_id,
      ts_ms:      ts_ms,
      ts_diff_ms: ts_diff_ms,
      wnd_size:   wnd_size,
      seq_nr:     seq_nr,
      ack_nr:     ack_nr,
      payload:    payload
    }
  end


end
