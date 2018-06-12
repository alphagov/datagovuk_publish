module CKAN
  module V26
    class SyncWorker
      def perform
        actions = CKAN::V26::PackageDiffer.new.call
        create_new_datasets(actions[:create])
        update_existing_datasets(actions[:update])
        delete_old_datasets(actions[:delete])
      end

    private

      def create_new_datasets(packages)
        packages.each do |package|
          ImportWorker.perform_async(package.get("id"))
        end
      end

      def update_existing_datasets(packages)
        packages.each do |package|
          ImportWorker.perform_async(package.get("id"))
        end
      end

      def delete_old_datasets(datasets)
        datasets.each(&:unpublish)
        datasets.destroy_all
      end
    end
  end
end
