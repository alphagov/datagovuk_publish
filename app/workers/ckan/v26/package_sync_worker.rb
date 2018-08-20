module CKAN
  module V26
    class PackageSyncWorker
      include Sidekiq::Worker
      sidekiq_options queue: :sync, retry: false

      def perform
        actions = PackageDiffer.new.call
        create_new_datasets(actions[:create])
        update_existing_datasets(actions[:update])
        delete_old_datasets(actions[:delete])
      end

    private

      def create_new_datasets(packages)
        packages.each do |package|
          PackageImportWorker.perform_async(package.get("id"))
        end
      end

      def update_existing_datasets(packages)
        packages.each do |package|
          PackageImportWorker.perform_async(package.get("id"))
        end
      end

      def delete_old_datasets(datasets)
        datasets.each(&:unpublish)
        datasets.destroy_all
        if datasets.length > 100
          msg = "More than 100 datasets have been unpublished in a single sync run.  This suggests a problem with the response from CKAN."
          Raven.capture msg
        end
      end
    end
  end
end
