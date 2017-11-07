class LegacySyncService
  attr_reader :dataset

  def initialize(dataset)
    @dataset = dataset
  end

  def send_update
    update_legacy_dataset
    update_legacy_datafiles
  end

  private

  def update_legacy_dataset
    Legacy::Dataset.new(dataset).update
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
