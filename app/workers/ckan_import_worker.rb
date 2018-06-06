require 'ckan/v26/client'

class CKANImportWorker
  include Sidekiq::Worker

  def perform(package_id)
    package = client.show_dataset(id: package_id)
    package["extras"] = hashify(package["extras"])
    dataset = Dataset.find_or_initialize_by(uuid: package_id)

    CKAN::V26::DatasetImporter.new.call(dataset, package)
    CKAN::V26::InspireImporter.new.call(dataset, package)
    CKAN::V26::LinkImporter.new.call(dataset, package)
  end

private

  def hashify(array = [])
    array.inject({}) do |result, hash|
      result[hash["key"]] = hash["value"]; result
    end
  end

  def client
    base_url = Rails.configuration.ckan_v26_base_url
    CKAN::V26::Client.new(base_url: base_url)
  end
end
