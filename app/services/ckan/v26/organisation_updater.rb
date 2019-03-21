module CKAN
  module V26
    class OrganisationUpdater
      def call(organisation, ckan_org)
        attributes = OrganisationMapper.new.call(ckan_org)
        organisation.assign_attributes(attributes)

        return unless organisation.changed?

        organisation.save
      end
    end
  end
end
