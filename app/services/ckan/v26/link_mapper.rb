module CKAN
  module V26
    class LinkMapper
      def call(resource, dataset)
        {
          url: resource.get("url"),
          format: resource.get("format"),
          name: build_name(resource),
          created_at: build_created_at(resource, dataset),
          updated_at: build_created_at(resource, dataset),
          type: build_type(resource),
          dataset_id: dataset.id
        }
      end

    private

      def build_created_at(resource, dataset)
        created = resource.get("created")
        return created if created.present?
        dataset.created_at
      end

      def build_name(resource)
        name = resource.get("name")
        description = resource.get("description")

        return name if name.present?
        return description if description.present?
        "No name specified"
      end

      def build_type(resource)
        type = resource.get("resource_type")
        type == "documentation" ? "Doc" : "Datafile"
      end
    end
  end
end
