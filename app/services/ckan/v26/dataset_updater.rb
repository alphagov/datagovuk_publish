module CKAN
  module V26
    class DatasetUpdater
      def call(dataset, package)
        attributes = DatasetMapper.new.call(package)
        dataset.assign_attributes(attributes)
        dataset.save
      end
    end
  end
end
