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
  def insert(request, stream) do
    IO.inspect(GRPC.Stream.get_headers(stream))
    token = Map.get(GRPC.Stream.get_headers(stream), "auth", "missing key")
    IO.inspect(token)
    source = Models.LogSource.get(request.source_id)
    IO.inspect(source)

    token =
      token
      |> Joken.token()
      |> Joken.with_signer(Joken.hs256(source.secret_key))


    case Joken.verify!(token) do
      {:ok, claims} ->
        IO.inspect(claims)
        {:ok, new} = Models.LogEntry.create(from_proto(request))
        IO.inspect(new)
        to_proto(new)

      {:error, message} ->
        raise message
    end
  end

  @spec get_n(Proto.EntryQuery.t(), GRPC.Server.Stream.t()) :: :ok
  def get_n(%Proto.EntryQuery{source_id: source_id, query: query}, stream) do
    IO.inspect(source_id)
    IO.inspect(query)
    res = Enum.map(Models.LogEntry.get_n(source_id, query), &to_proto/1)
    Enum.each(res, fn e -> GRPC.Server.send_reply(stream, e) end)
  end
end
