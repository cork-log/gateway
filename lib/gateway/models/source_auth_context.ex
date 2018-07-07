defmodule Gateway.Models.SourceAuthContext do
  use Gateway.Models.Model
  import Ecto.Query
  alias Gateway.Models
  alias Gateway.Models.SourceAuthContext
  alias Gateway.Repo

  schema "source_auth_context" do
    field(:name, :string)
    field(:enabled, :boolean)
    belongs_to(:source, Models.LogSource)
  end

  def create(%{source_id: source_id, name: name}) do
    model = %SourceAuthContext{name: name, enabled: true, source_id: source_id}
    Repo.insert(model)
  end

  def toggle(token_id) do
    token = Repo.get!(SourceAuthContext, token_id)
    state = not token.enabled

    SourceAuthContext
    |> where([x], x.id == ^token_id)
    |> Repo.update_all(set: [enabled: state])
  end

  def get_context(context_id) do
    SourceAuthContext
    |> preload(:source)
    |> Repo.get(context_id)
  end

  def get_auth_contexts(source_id) do
    SourceAuthContext
    |> where([x], x.source_id == ^source_id)
    |> Repo.all()
  end
end
