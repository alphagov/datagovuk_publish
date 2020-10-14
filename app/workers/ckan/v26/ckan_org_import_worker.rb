module CKAN
  module V26
    class CKANOrgImportWorker
      include Sidekiq::Worker
      sidekiq_options queue: :import, retry: 3 # Discarded after ~2 minutes

      def perform(organisation_id, *_args)
        ckan_org = get_organization_from_ckan(organisation_id)
        organisation = Organisation.find_or_initialize_by(name: organisation_id)
        update_organisation_from_ckan(ckan_org, organisation)
      end

    private

      def update_organisation_from_ckan(ckan_org, organisation)
        Organisation.transaction do
          result = OrganisationUpdater.new.call(organisation, ckan_org)
          republish_organisation_datasets(organisation) if result
        end
      end

      def republish_organisation_datasets(organisation)
        organisation.datasets.select(&:published?).each(&:publish)
      end

      def get_organization_from_ckan(organisation_id)
        base_url = Rails.configuration.ckan_v26_base_url
        client = CKAN::V26::Client.new(base_url: base_url)

        response = client.show_organization(id: organisation_id)
        CKANOrg.new(response)
      end
    end
  end
end
