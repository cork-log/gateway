defmodule Gateway.Service.LogEntryService do
  use GRPC.Server, service: Proto.LogEntry.Service

  alias Gateway.Models

  def to_proto(entry) do
    Proto.Entry.new(
      id: entry.id,
      source_id: entry.source_id,
      content: entry.content,
      tag: entry.tag,
      level: entry.level,
      timestamp_occurred: entry.time_occurred,
      timestamp_stored: entry.time_stored
    )
  end
  def from_proto(entry) do
    %Models.LogEntry{
      source_id: entry.source_id,
      content: entry.content,
      tag: entry.tag,
      level: entry.level,
      time_occurred: entry.timestamp_occurred
    }
  end

  @spec insert(Proto.NewEntry.t(), GRPC.Server.Stream.t()) :: Proto.LogEntry.t()
  def insert(request, _stream) do
    {:ok, new} = Gateway.Models.LogEntry.create(from_proto(request))
    IO.inspect(new)
    to_proto(new)
  end
end
