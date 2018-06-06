module CKAN
  module V26
    class LinkImporter
      def call(dataset, package)
        remove_missing_links(dataset, package)

        package["resources"].each do |resource|
          create_or_update_link(dataset, resource)
        end
      end

    private

      def create_or_update_link(dataset, resource)
        link = Link.find_or_initialize_by(uuid: resource["id"])
        link.name = "name"
        link.dataset_id = dataset.id
        link.save
      end

      def remove_missing_links(dataset, package)
        resource_ids = package["resources"]
          .map { |resource| resource["id"] }

        Link.where(dataset_id: dataset.id)
            .where.not(uuid: resource_ids)
            .destroy_all
      end
    end
  end
end
