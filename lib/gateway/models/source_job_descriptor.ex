defmodule Gateway.Models.SourceJobDescriptor do
  use Gateway.Models.Model
  import Ecto.Query
  alias Gateway.Models
  alias Gateway.Models.SourceJobDescriptor
  alias Gateway.Models.JobStatusType
  alias Gateway.Repo

  schema "source_job_descriptor" do
    field(:name, :string)
    field(:tolerance, :float)
    # in hours
    field(:frequency, :integer)
    # Expect time based on rolling average
    field(:time, :utc_datetime)
    belongs_to(:source, Models.LogSource)
    has_many(:status_types, JobStatusType, foreign_key: :job_descriptor_id)
    field(:expected_at, :string, virtual: true)
  end

  defp reformatDate(d = %SourceJobDescriptor{time: time}) do
    if(is_nil(time)) do
      Map.put(d, :expected_at, "")
    else
      Map.put(d, :expected_at, DateTime.to_unix(time, :millisecond))
    end
  end

  def create(%{source_id: source_id, name: name, tolerance: tolerance, frequency: frequency}) do
    model = %SourceJobDescriptor{
      name: name,
      source_id: source_id,
      tolerance: tolerance,
      frequency: frequency
    }

    {:ok, resp} = Repo.insert(model)
    {:ok, reformatDate(resp)}
  end

  def get_job(id) do
    SourceJobDescriptor
    |> preload(:source)
    |> Repo.get(id)
    |> reformatDate()
  end

  def get_jobs(source_id) do
    Enum.map(
      SourceJobDescriptor
      |> where([x], x.source_id == ^source_id)
      |> Repo.all(),
      &reformatDate/1
    )
  end

  def modify_job(%{id: id, name: name, tolerance: tolerance, frequency: freq}) do
    {1, nil} =
      SourceJobDescriptor
      |> where([x], x.id == ^id)
      |> Repo.update_all(set: [name: name, tolerance: tolerance, frequency: freq])

    {:ok}
  end
end
