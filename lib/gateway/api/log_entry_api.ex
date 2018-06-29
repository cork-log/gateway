defmodule Gateway.Service.LogEntryService do
  use GRPC.Server, service: Proto.LogEntry.Service
  use Cartograf
  alias Gateway.Models

  map(Models.LogEntry, Proto.Entry, :to_proto, auto: true) do
    let(:time_occurred, :timestamp_occurred)
    let(:time_stored, :timestamp_stored)
    # fk
    drop(:source)
    drop(:__meta__)
  end

  map(Proto.NewEntry, Models.LogEntry, :from_proto, auto: true, map: true) do
    let(:timestamp_occurred, :time_occurred)
  end

  @spec insert(Proto.NewEntry.t(), GRPC.Server.Stream.t()) :: Proto.LogEntry.t()
  def insert(request, _stream) do
    {:ok, new} = Models.LogEntry.create(from_proto(request))
    IO.inspect(new)
    to_proto(new)
  end

  @spec get_n(Proto.EntryQuery.t(), GRPC.Server.Stream.t()) :: :ok
  def get_n(%Proto.EntryQuery{source_id: source_id, query: query}, stream) do
    IO.inspect(source_id)
    IO.inspect(query)
    res = Enum.map(Models.LogEntry.get_n(source_id, query), &to_proto/1)
    Enum.each(res, fn e -> GRPC.Server.send_reply(stream, e) end)
  end
end
