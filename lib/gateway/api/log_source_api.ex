defmodule Gateway.Service.LogSourceService do
  use GRPC.Server, service: Proto.LogSource.Service
  require Logger
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
end
