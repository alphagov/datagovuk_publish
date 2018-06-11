require 'ckan/v26/client'

class CKANImportWorker
  include Sidekiq::Worker

  def perform(package_id)
    response = client.show_dataset(id: package_id)
    package = CKAN::V26::Package.new(response)
    dataset = Dataset.find_or_initialize_by(uuid: package_id)

    Dataset.transaction do
      CKAN::V26::DatasetUpdater.new.call(dataset, package)
      CKAN::V26::InspireUpdater.new.call(dataset, package)
      CKAN::V26::LinkUpdater.new.call(dataset, package)
    end
  end

private

  def client
    base_url = Rails.configuration.ckan_v26_base_url
    CKAN::V26::Client.new(base_url: base_url)
  end
end
