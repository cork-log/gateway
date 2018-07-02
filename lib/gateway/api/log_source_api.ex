defmodule Gateway.Service.LogSourceService do
  use GRPC.Server, service: Proto.LogSource.Service
  use Cartograf
  require Logger
  alias Gateway.Models

  map(Models.LogSource, Proto.Source, :to_proto, auto: true) do
    drop(:__meta__)
  end


  @spec create(Proto.NewSource.t, GRPC.Server.Stream.t) :: Proto.LogSource.t
  def create(request, _stream) do
    Logger.info("source>create :: #{inspect request}")
    {:ok, new} = Gateway.Models.LogSource.create(request.name)
    Proto.Source.new(name: new.name , id: new.id)
  end

  @spec get(Proto.IdQuery.t, GRPC.Server.Stream.t) :: Proto.LogSource.t
  def get(request, _stream) do
    Logger.info("source>get :: #{inspect request}")
    existing = Gateway.Models.LogSource.get(request.id)
    Proto.Source.new(name: existing.name , id: existing.id)
  end

  @spec get_sources(Proto.Empty.t, GRPC.Server.Stream.t()) :: :ok
  def get_sources(_empty, stream) do
    res = Enum.map(Models.LogSource.get_sources(), &to_proto/1)
    Enum.each(res, fn e -> GRPC.Server.send_reply(stream, e) end)
  end
end
