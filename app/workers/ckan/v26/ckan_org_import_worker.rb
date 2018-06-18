require 'ckan/v26/client'

module CKAN
  module V26
    class CKANOrgImportWorker
      include Sidekiq::Worker

      def perform(organisation_id, *_args)
        ckan_org = get_organization_from_ckan(organisation_id)
        organisation = Organisation.find_or_initialize_by(name: organisation_id)
        update_organisation_from_ckan(ckan_org, organisation)
      end

    private

      def update_organisation_from_ckan(ckan_org, organisation)
        Organisation.transaction do
          OrganisationUpdater.new.call(organisation, ckan_org)
        end
      end

      def get_organization_from_ckan(organisation_id)
        base_url = Rails.configuration.ckan_v26_base_url
        client = Client.new(base_url: base_url)

        response = client.show_organization(id: organisation_id)
        CKANOrg.new(response)
      end
    end
  end
end
