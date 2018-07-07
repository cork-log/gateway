defmodule Gateway.Service.LogSourceService do
  use GRPC.Server, service: Proto.LogSource.Service
  use Cartograf
  require Logger
  alias Gateway.Models
  import Joken

  map(Models.LogSource, Proto.Source, :to_proto, auto: true) do
    drop(:__meta__)
    drop(:secret_key)
    drop(:contexts)
  end

  def source_to_proto(s = %Models.LogSource{}) do
    Map.put(to_proto(s), :contexts, Enum.map(s.contexts, &auth_to_proto/1))
  end

  map(Models.SourceAuthContext, Proto.AuthContext, :auth_to_proto, auto: true) do
    drop(:__meta__)
    drop(:source)
  end

  @spec create(Proto.NewSource.t(), GRPC.Server.Stream.t()) :: Proto.LogSource.t()
  def create(request, _stream) do
    Logger.info("source>create :: #{inspect(request)}")
    {:ok, new} = Gateway.Models.LogSource.create(request.name)
    Proto.Source.new(name: new.name, id: new.id)
  end

  @spec get(Proto.IdQuery.t(), GRPC.Server.Stream.t()) :: Proto.LogSource.t()
  def get(request, _stream) do
    Logger.info("source>get :: #{inspect(request)}")
    existing = Gateway.Models.LogSource.get(request.id)

    source_to_proto(existing)
  end

  @spec get_sources(Proto.Empty.t(), GRPC.Server.Stream.t()) :: :ok
  def get_sources(_empty, stream) do
    res = Enum.map(Models.LogSource.get_sources(), &source_to_proto/1)
    Enum.each(res, fn e -> GRPC.Server.send_reply(stream, e) end)
  end

  @spec create_auth_context(Proto.NewAuthContext.t(), GRPC.Server.Stream.t()) ::
          Proto.AuthContext.t()
  def create_auth_context(new, _stream) do
    {:ok, new} = Models.SourceAuthContext.create(new)
    auth_to_proto(new)
  end

  @spec request_token(Proto.IdQuery.t(), GRPC.Server.Stream.t()) :: Proto.TokenResponse
  def request_token(req, _stream) do
    IO.inspect(req)
    context = Models.SourceAuthContext.get_context(req.id)
    IO.inspect(context)

    jwt =
      token(%{token_id: context.id, source_id: context.source_id})
      |> with_signer(hs256(context.source.secret_key))
      |> sign()

    %Proto.TokenResponse{token: jwt.token}
  end

  @spec toggle_auth_context(Proto.IdQuery.t(), GRPC.Server.Stream.t()) :: Proto.AuthContext.t()
  def toggle_auth_context(request, _stream) do
    Models.SourceAuthContext.toggle(request.id)
    auth_to_proto(Models.SourceAuthContext.get_context(request.id))
  end

  @spec get_auth_contexts(Proto.IdQuery.t(), GRPC.Server.Stream.t()) :: :ok
  def get_auth_contexts(request, stream) do
    responses = Enum.map(Models.SourceAuthContext.get_auth_contexts(request.id), &auth_to_proto/1)
    Enum.each(responses, fn e -> GRPC.Server.send_reply(stream, e) end)
  end
end
