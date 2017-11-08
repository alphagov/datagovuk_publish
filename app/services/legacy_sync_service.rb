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
    Legacy::Dataset.new(dataset).update
  end

  def create_legacy_dataset
    Legacy::Dataset.new(dataset).create
  end

  def update_legacy_datafiles
    datafiles_modified_since_latest_publication.each do |datafile|
      Legacy::Datafile.new(datafile).update
    end
  end

  def datafiles_modified_since_latest_publication
    Datafile
      .where(dataset_id: dataset.id)
      .updated_since_creation
      .updated_after_date(dataset.last_published_at)
  end
end
