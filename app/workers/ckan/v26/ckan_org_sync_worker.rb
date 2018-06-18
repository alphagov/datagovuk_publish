module CKAN
  module V26
    class CKANOrgSyncWorker
      include Sidekiq::Worker

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
        Organisation.where(name: organisation_ids).destroy_all
      end
    end
  end
end
