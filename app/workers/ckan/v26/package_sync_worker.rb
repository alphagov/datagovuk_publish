module CKAN
  module V26
    class PackageSyncWorker
      include Sidekiq::Worker
      sidekiq_options queue: :sync, retry: false

      def perform
        logger.info(">>> perform")
        actions = PackageDiffer.new.call
        create_new_datasets(actions[:create])
        update_existing_datasets(actions[:update])
        delete_old_datasets(actions[:delete])
      end

    private

      def create_new_datasets(packages)
        logger.info(">>> create_new_datasets")
        packages.each do |package|
          logger.info(">>> package: #{package.get("id")}")
          PackageImportWorker.perform_async(package.get("id"))
          logger.info(">>> after PackageImportWorker.perform_async")
        end
      end

      def update_existing_datasets(packages)
        logger.info(">>> update_new_datasets")
        packages.each do |package|
          logger.info(">>> package: #{package}")
          PackageImportWorker.perform_async(package.get("id"))
          logger.info(">>> after PackageImportWorker.perform_async")
        end
      end

      def delete_old_datasets(datasets)
        datasets.each(&:unpublish)
        datasets.destroy_all
      end
    end
  end
end
