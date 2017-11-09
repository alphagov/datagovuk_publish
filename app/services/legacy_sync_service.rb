class LegacySyncService
  attr_reader :dataset

  def initialize(dataset)
    @dataset = dataset
  end

  def sync
    if already_published?
      send_update
    else
      send_create
    end
  end

  def send_update
    update_legacy_dataset
    update_legacy_datafiles
  end

  def send_create
    create_legacy_dataset
  end

  private

  def already_published?
    dataset.published_date.present?
  end

  def update_legacy_dataset
    LegacyUpdateWorker.perform_async(dataset.id)
  end

  def create_legacy_dataset
    LegacyCreateWorker.perform_async(dataset.id)
  end

  def update_legacy_datafiles
    datafiles_modified_since_latest_publication.each do |datafile|
      LegacyUpdateDatafileWorker.perform_async(datafile.id)
    end
  end

  def datafiles_modified_since_latest_publication
    Datafile
      .where(dataset_id: dataset.id)
      .updated_since_creation
      .updated_after_date(dataset.last_published_at)
  end
end
