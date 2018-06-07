module CKAN
  module V26
    class LinkImporter
      def call(dataset, package)
        remove_missing_links(dataset, package)

        package.get("resources").each do |resource|
          resource = CKAN::V26::Resource.new(resource)
          create_or_update_link(dataset, resource)
        end
      end

    private

      def create_or_update_link(dataset, resource)
        link = Link.find_or_initialize_by(uuid: resource.get("id"))
        attributes = LinkMapper.new.call(resource, dataset)

        link.assign_attributes(attributes)
        link.save
      end

      def remove_missing_links(dataset, package)
        resource_ids = package.get("resources")
          .map { |resource| resource["id"] }

        Link.where(dataset_id: dataset.id)
            .where.not(uuid: resource_ids)
            .destroy_all
      end
    end
  end
end
