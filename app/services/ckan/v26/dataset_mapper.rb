module CKAN
  module V26
    class DatasetMapper
      def call(dataset, package)
        dataset.title = "title"
        dataset.summary = "summary"
        dataset.last_updated_at = package["metadata_modified"]
        dataset.organisation = find_organisation(package)
      end

    private

      def find_organisation(package)
        Organisation.find_by(uuid: package["owner_org"])
      end
    end
  end
end
