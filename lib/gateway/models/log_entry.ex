defmodule Gateway.Models.LogEntry do
  use Gateway.Models.Model

  import Ecto.Query
  alias Gateway.Models.LogEntry
  alias Gateway.Repo

  schema "log_Entry" do
    belongs_to(:source, Gateway.Models.LogSource)
    field(:level, :string)
    field(:tag, :string)
    field(:content, :string)
    field(:time_occurred, :string)
    field(:time_stored, :string)
  end

  @spec create(LogEntry) :: LogEntry
  def create(entry) do
    unix_now = DateTime.to_unix(DateTime.utc_now(), :millisecond)
    entry = %LogEntry{entry | time_stored: Integer.to_string(unix_now)}
    Repo.insert(entry)
  end

  @spec get(String.t()) :: LogEntry
  def get(id) do
    Repo.one(from(u in LogEntry, where: u.id == ^id))
  end

  def get_n(source_id, %{take: take, direction: dir, last_timestamp: ts}) do
    dir = if(:ASCENDING == Proto.Direction.key(dir), do: :asc, else: :desc)

    query =
      LogEntry
      |> where([e], e.source_id == ^source_id)
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
