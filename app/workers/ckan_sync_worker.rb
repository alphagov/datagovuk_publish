class CKANSyncWorker
  def perform
    actions = CKAN::V26::VersionDiff.new.call
    create_new_datasets(actions[:create])
    update_existing_datasets(actions[:update])
    delete_old_datasets(actions[:delete])
  end

private

  def create_new_datasets(packages)
    packages.each do |package|
      Dataset.create(title: "title",
                     summary: "summary",
                     organisation: Organisation.first,
                     uuid: package["id"],
                     last_updated_at: package["metadata_modified"])
    end
  end

  def update_existing_datasets(packages)
    packages.each do |package|
      dataset = Dataset.find_by(uuid: package["id"])
      dataset.update(last_updated_at: package["metadata_modified"])
    end
  end

  def delete_old_datasets(datasets)
    datasets.destroy_all
  end
end
