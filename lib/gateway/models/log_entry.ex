defmodule Gateway.Models.LogEntry do
  use Gateway.Models.Model

  import Ecto.Query, only: [from: 2]
  alias Gateway.Models.LogEntry
  alias Gateway.Repo

  # weather is the MongoDB collection name
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
end
