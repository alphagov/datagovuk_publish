module CKAN
  module V26
    class PackageImportWorker
      include Sidekiq::Worker
      sidekiq_options queue: :import, retry: 3 # Discarded after ~2 minutes

      def perform(package_id, *_args)
        package = get_package_from_ckan(package_id)
        dataset = Dataset.find_or_initialize_by(uuid: package_id)
        update_dataset_from_package(package, dataset)
      rescue OpenURI::HTTPError
        raise if Rails.env.production?
      end

    private

      def update_dataset_from_package(package, dataset)
        Dataset.transaction do
          DatasetUpdater.new.call(dataset, package)
          InspireUpdater.new.call(dataset, package)
          LinkUpdater.new.call(dataset, package)
          dataset.publish
        end
      end

      def get_package_from_ckan(package_id)
        base_url = Rails.configuration.ckan_v26_base_url
        client = CKAN::V26::Client.new(base_url: base_url)

        response = client.show_dataset(id: package_id)
        Package.new(response)
      end
    end
  end
end
