module CKAN
  module V26
    class CKANOrgDiffer
      def call
        organisation_ids = client.list_organization

        {
          create_update: organisation_ids,
          delete: diff_delete(organisation_ids),
        }
      end

    private

      def diff_create_update(organisation_ids)
        organisation_ids
      end

      def diff_delete(organisation_ids)
        Organisation.where(govuk_content_id: nil)
          .where.not(name: organisation_ids).pluck(:name)
      end

      def client
        base_url = Rails.configuration.ckan_v26_base_url
        CKAN::V26::Client.new(base_url: base_url)
      end
    end
  end
end
