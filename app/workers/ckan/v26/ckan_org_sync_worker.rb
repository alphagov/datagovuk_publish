module CKAN
  module V26
    class CKANOrgSyncWorker
      include Sidekiq::Worker
      sidekiq_options queue: :sync, retry: 13 # Discarded after ~17 hours

      def perform
        actions = CKANOrgDiffer.new.call
        create_update_organisations(actions[:create_update])
        delete_old_organisations(actions[:delete])
      end

    private

      def create_update_organisations(organisation_ids)
        organisation_ids.each do |organisation_id|
          CKANOrgImportWorker.perform_async(organisation_id)
        end
      end

      def delete_old_organisations(organisation_ids)
        organisations = Organisation.where(name: organisation_ids)
        Dataset.where(organisation: organisations).find_each(&:unpublish)
        organisations.destroy_all
      end
    end
  end
end
