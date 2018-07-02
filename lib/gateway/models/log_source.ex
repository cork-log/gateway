defmodule Gateway.Models.LogSource do
  use Gateway.Models.Model

  import Ecto.Query, only: [from: 2]
  alias Gateway.Models.LogSource
  alias Gateway.Repo

  # weather is the MongoDB collection name
  schema "log_source" do
    field(:name, :string)
  end

  @spec create(String.t()) :: {:ok, LogSource}
  def create(name) do
    source = %LogSource{name: name}
    Repo.insert(source)
  end

  @spec get(String.t()) :: LogSource
  def get(id) do
    Repo.one(from(u in LogSource, where: u.id == ^id))
  end

  def get_sources do
    LogSource
    |> Repo.all()
  end
end
