module CKAN
  module V26
    class InspireImporter
      def call(dataset, package)
        if inspire?(package)
          InspireDataset.find_or_create_by(dataset_id: dataset.id)
        else
          InspireDataset.where(dataset_id: dataset.id).destroy_all
        end
      end

    private

      def inspire?(package)
        package["extras"]["UKLP"] == "True"
      end
    end
  end
end
