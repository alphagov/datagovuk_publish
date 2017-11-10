class LegacySyncService
  attr_reader :dataset

  def initialize(dataset)
    @dataset = dataset
  end

  def sync
    sync_dataset
    sync_datafiles
  end

  private

  def sync_dataset
    if dataset.published_date.present?
      update_legacy_dataset
    else
      create_legacy_dataset
    end
  end

  def sync_datafiles
    create_legacy_datafiles
    update_legacy_datafiles
  end

  def update_legacy_dataset
    ::LegacyDatasetUpdateWorker.perform_async(dataset.id)
  end

  def create_legacy_dataset
    ::LegacyDatasetCreateWorker.perform_async(dataset.id)
  end

  def create_legacy_datafiles
    datafiles_created_since_latest_publication.each do |datafile|
      ::LegacyDatafileCreateWorker.perform_async(datafile.id)
    end
  end

  def update_legacy_datafiles
    datafiles_modified_since_latest_publication.each do |datafile|
      ::LegacyDatafileUpdateWorker.perform_async(datafile.id)
    end
  end

  def datafiles_created_since_latest_publication
    Datafile
      .where(dataset_id: dataset.id)
      .created_after_date(dataset.last_published_at)
  end

  def datafiles_modified_since_latest_publication
    Datafile
      .where(dataset_id: dataset.id)
      .created_before_date(dataset.last_published_at)
      .updated_after_date(dataset.last_published_at)
  end
end
