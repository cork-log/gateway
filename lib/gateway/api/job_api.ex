defmodule Gateway.Service.SourceJobService do
  use GRPC.Server, service: Proto.SourceJob.Service
  use Cartograf
  require Logger
  alias Gateway.Models.SourceJobDescriptor
  alias Gateway.Models.SourceJobEntry
  alias Gateway.Models.JobStatusType

  map(SourceJobDescriptor, Proto.JobDescriptor, :descriptor_to_proto, auto: true) do
    drop(:__meta__)
    drop(:source)
    drop(:jobs)
    drop(:time)
    drop(:status_types)
  end

  map(JobStatusType, Proto.JobStatusType, :type_to_proto, auto: true) do
    drop(:__meta__)
    drop(:job_descriptor)
  end

  map(SourceJobEntry, Proto.JobStatusEntry, :entry_to_proto, auto: true) do
    drop(:__meta__)
    drop(:job_descriptor)
  end

  def create_job_descriptor(descriptor = %Proto.NewJobDescriptor{}, _stream) do
    case SourceJobDescriptor.create(descriptor) do
      {:ok, descriptor = %SourceJobDescriptor{}} ->
        descriptor_to_proto(descriptor)

      {:error, msg} ->
        {:error, msg}
    end
  end

  def create_job_status_type(status_type = %Proto.JobStatusType{}, _stream) do
    case JobStatusType.create(status_type) do
      {:ok, resp} -> type_to_proto(resp)
      {:error, msg} -> {:error, msg}
    end
  end

  def create_job_status_entry(status_entry = %Proto.JobStatusEntry{}, _stream) do
    case SourceJobEntry.create(status_entry) do
      {:ok, resp} -> entry_to_proto(resp)
      {:error, msg} -> {:error, msg}
    end
  end

  def get_jobs(%Proto.IdQuery{id: id}, stream) do
    jobs = SourceJobDescriptor.get_jobs(id)
    Util.map_stream(jobs, &descriptor_to_proto/1, stream)
  end

  def get_status_types(%Proto.IdQuery{id: id}, stream) do
    case JobStatusType.get_types(id) do
      {:ok, types} ->
        Util.map_stream(types, &type_to_proto/1, stream)

      {:error, msg} ->
        {:error, msg}
    end
  end

  def modify_job_descriptor(job = %Proto.JobDescriptor{}, _stream) do
    Logger.info("Got job #{inspect(job)}")

    case SourceJobDescriptor.modify_job(job) do
      {:ok } -> descriptor_to_proto(SourceJobDescriptor.get_job(job.id))
      {:error, msg} -> {:error, msg}
    end
  end

  def modify_job_status_type(type = %Proto.JobStatusType{}, stream) do
    case JobStatusType.modify_type(type) do
      {:ok, updated} -> type_to_proto(updated)
      {:error, msg} -> {:error, msg}
    end
  end

  def get_job_entries(%Proto.JobEntryQuery{job_descriptor_id: id, query: query}, stream) do
    case SourceJobEntry.get_n(id, query) do
      {:ok, entries} -> Util.map_stream(entries, &entry_to_proto/1, stream)
      {:error, msg} -> {:error, msg}
    end
  end

  """
  get_job_entries
  """
end
