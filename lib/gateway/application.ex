defmodule Gateway.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  import Supervisor.Spec
  alias Gateway.Service.LogSourceService
  alias Gateway.Service.LogEntryService

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      supervisor(GRPC.Server.Supervisor, [{[LogSourceService, LogEntryService], 50051}]),
      worker(Gateway.Repo, [])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Gateway.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
