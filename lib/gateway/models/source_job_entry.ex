defmodule Gateway.Models.SourceJobEntry do
  use Gateway.Models.Model

  import Ecto.Query
  alias Gateway.Models.SourceJobEntry
  alias Gateway.Repo

  schema "source_job_entry" do
    belongs_to(:job_descriptor, Gateway.Models.SourceJobDescriptor)
    has_one(:type, Gateway.Models.JobStatusType)
    field(:note, :string)
    # easily derived, but precomputing for stats
    field(:late, :boolean)
    field(:time_expected_at, :string)
    field(:time_occurred, :string)
    field(:time_stored, :string)
  end

  @spec create(SourceJobEntry) :: {:ok, SourceJobEntry}
  def create(entry) do
    unix_now = DateTime.to_unix(DateTime.utc_now(), :millisecond)
    entry = %SourceJobEntry{entry | time_stored: Integer.to_string(unix_now)}
    Repo.insert(entry)
  end

  @spec get(String.t()) :: SourceJobEntry
  def get(id) do
    Repo.one(from(u in SourceJobEntry, where: u.id == ^id))
  end

  def get_n(job_descriptor_id, %{take: take, direction: dir, last_timestamp: ts}) do
    dir = if(:ASCENDING == Proto.Direction.key(dir), do: :asc, else: :desc)

    query =
      SourceJobEntry
      |> where([e], e.job_descriptor_id == ^job_descriptor_id)
      |> order_by([e], {^dir, e.time_occurred})
      |> limit(^take)

    case dir do
      :asc ->
        query
        |> where([e], e.time_occurred <= ^ts)
        |> Repo.all()

      :desc ->
        query
        |> where([e], e.time_occurred >= ^ts)
        |> Repo.all()
    end
  end
end
