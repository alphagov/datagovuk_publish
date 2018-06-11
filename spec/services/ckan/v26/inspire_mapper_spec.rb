require 'rails_helper'

describe CKAN::V26::InspireMapper do
  let(:package) { build :ckan_v26_package, :inspire }

  describe '#call' do
    it 'returns the mapped inspire attributes for a package' do
      attributes = subject.call(package)

      expect(attributes[:access_constraints]).to eq package.get_extra("access_constraints")
      expect(attributes[:bbox_east_long]).to eq package.get_extra("bbox-east-long")
      expect(attributes[:bbox_north_lat]).to eq package.get_extra("bbox-north-lat")
      expect(attributes[:bbox_south_lat]).to eq package.get_extra("bbox-south-lat")
      expect(attributes[:bbox_west_long]).to eq package.get_extra("bbox-west-long")
      expect(attributes[:coupled_resource]).to eq package.get_extra("bbox-west-long")
      expect(attributes[:dataset_reference_date]).to eq package.get_extra("dataset-reference-date")
      expect(attributes[:frequency_of_update]).to eq package.get_extra("frequency-of-update")
      expect(attributes[:harvest_object_id]).to eq package.get_extra("harvest_object_id")
      expect(attributes[:harvest_source_reference]).to eq package.get_extra("harvest_source_reference")
      expect(attributes[:import_source]).to eq package.get_extra("import_source")
      expect(attributes[:metadata_date]).to eq package.get_extra("metadata-date")
      expect(attributes[:metadata_language]).to eq package.get_extra("metadata-language")
      expect(attributes[:provider]).to eq package.get_extra("provider")
      expect(attributes[:resource_type]).to eq package.get_extra("resource-type")
      expect(attributes[:responsible_party]).to eq package.get_extra("responsible-party")
      expect(attributes[:spatial]).to eq package.get_extra("spatial")
      expect(attributes[:spatial_data_service_type]).to eq package.get_extra("spatial-data-service-type")
      expect(attributes[:spatial_reference_system]).to eq package.get_extra("spatial-reference-system")
      expect(attributes[:guid]).to eq package.get_extra("guid")
    end
  end
end
