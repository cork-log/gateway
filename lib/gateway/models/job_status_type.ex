defmodule Gateway.Models.JobStatusType do
  alias __MODULE__
  use Gateway.Models.Model
  alias Gateway.Repo

  import Ecto.Query

  schema "job_status_type" do
    field(:value, :integer)
    belongs_to(:job_descriptor, Gateway.Models.SourceJobDescriptor)
    field(:name, :string)
    field(:good, :boolean)
  end

  def create(%{value: val, name: name, good: good?, descriptor_id: id}) do
    not_used? =
      JobStatusType
      # enforce compound key
      |> where([x], x.value == ^val and x.job_descriptor_id == ^id)
      |> Repo.one() == nil

    if(not_used?) do
      entry = %JobStatusType{value: val, name: name, good: good?, job_descriptor_id: id}
      Repo.insert(entry)
    else
      {:error, {:already_exists, %{value: val}}}
    end
  end

  def get_types(job_desc_id) do
    JobStatusType
    |> where([x], x.job_descriptor_id == ^job_desc_id)
    |> Repo.all()
  end

  def modify_type(%{name: name, good: good?, value: val, id: id}) do
    JobStatusType
    |> where([x], x.id == ^id)
    |> Repo.update_all([name: name, good: good?, value: val])
  end
end
