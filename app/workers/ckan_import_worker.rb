class CKANImportWorker
  include Sidekiq::Worker

  def perform(package_id)
    package = client.show_dataset(id: package_id)
    dataset = Dataset.find_or_initialize_by(uuid: package_id)

    update_dataset_attributes(dataset, package)
  end

private

  def update_dataset_attributes(dataset, package)
    CKAN::V26::DatasetMapper.new.call(dataset, package)
    dataset.save
  end

  def client
    base_url = Rails.configuration.ckan_v26_base_url
    CKAN::V26::Client.new(base_url: base_url)
  end
end
