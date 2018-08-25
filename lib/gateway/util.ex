defmodule Util do
  def map_stream(list, fun, stream) do
    Enum.each(Enum.map(list, fun), fn e ->
      GRPC.Server.send_reply(stream, e)
    end)
  end
end
