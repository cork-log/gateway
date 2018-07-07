defmodule Gateway.Models.LogSource do
  use Gateway.Models.Model

  import Ecto.Query
  alias Gateway.Models.LogSource
  alias Gateway.Models
  alias Gateway.Repo

  schema "log_source" do
    field(:name, :string)
    field(:secret_key, :string)
    has_many(:contexts, Models.SourceAuthContext, foreign_key: :source_id)
  end

  @spec create(String.t()) :: {:ok, LogSource}
  def create(name) do
    secret = UUID.uuid3(UUID.uuid1(:hex), UUID.uuid4(:hex), :hex)
    source = %LogSource{name: name, secret_key: secret}
    Repo.insert(source)
  end

  @spec get(String.t()) :: LogSource
  def get(id) do
    LogSource
    |> preload(:contexts)
    |> where([u], u.id == ^id)
    |> Repo.one()
  end

  def get_sources do
    LogSource
    |> preload(:contexts)
    |> Repo.all()
  end
end
