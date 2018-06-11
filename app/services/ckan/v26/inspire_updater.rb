module CKAN
  module V26
    class InspireUpdater
      def call(dataset, package)
        if inspire?(package)
          create_or_update_inspire_dataset(dataset, package)
        else
          destroy_inspire_dataset(dataset)
        end
      end

    private

      def create_or_update_inspire_dataset(dataset, package)
        inspire_dataset = InspireDataset.find_or_initialize_by(dataset_id: dataset.id)
        attributes = InspireMapper.new.call(package)

        inspire_dataset.assign_attributes(attributes)
        inspire_dataset.save
      end

      def destroy_inspire_dataset(dataset)
        InspireDataset.where(dataset_id: dataset.id).destroy_all
      end

      def inspire?(package)
        package.get_extra("UKLP")
      end
    end
  end
end
