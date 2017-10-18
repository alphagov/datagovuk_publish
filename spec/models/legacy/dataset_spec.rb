require 'rails_helper'

describe Legacy::Dataset do
  describe "#metadata_json" do
    context "when frequency format is not supported by legacy" do
      it "adds additional paramaters to the json" do
         dataset = FactoryGirl.create(:dataset, frequency: 'daily')
         legacy_dataset = Legacy::Dataset.new(dataset)
         legacy_dataset_json_metadata = {
           'id': dataset.uuid,
           'name' => dataset.name,
           'title' => dataset.title,
           'notes' => dataset.summary,
           'description' => dataset.summary,
           'organization' => {
             'name' => dataset.organisation.name
           },
           'update_frequency' => 'other',
           'update_frequency-other' => 'daily',
           'extras' => [{"key" => "update_frequency",
                         "package_id" => dataset.uuid,
                         "value" => 'other'},
                        {"key" => "update_frequency-other",
                         "package_id" => dataset.uuid,
                         "value" => 'daily'}
                       ],
           'unpublished' => !dataset.published?,
           'metadata_created' => dataset.created_at,
           'metadata_modified' => dataset.last_updated_at,
           'geographic_coverage' => [dataset.location1.to_s.downcase],
           'license_id' => dataset.licence
         }.to_json
         expect(legacy_dataset.metadata_json).to eql legacy_dataset_json_metadata
      end
    end
    context "when frequency format is supported by legacy" do
      it "outputs json for legacy" do
        dataset = FactoryGirl.create(:dataset, frequency: 'annually')
        legacy_dataset = Legacy::Dataset.new(dataset)
        legacy_dataset_json_metadata = {
          'id': dataset.uuid,
          'name' => dataset.name,
          'title' => dataset.title,
          'notes' => dataset.summary,
          'description' => dataset.summary,
          'organization' => {
            'name' => dataset.organisation.name
          },
          'update_frequency' => 'annual',
          'extras' => [{"key" => "update_frequency",
                        "package_id" => dataset.uuid,
                        "value" => 'annual'}
                      ],
          'unpublished' => !dataset.published?,
          'metadata_created' => dataset.created_at,
          'metadata_modified' => dataset.last_updated_at,
          'geographic_coverage' => [dataset.location1.to_s.downcase],
          'license_id' => dataset.licence
        }.to_json
        expect(legacy_dataset.metadata_json).to eql legacy_dataset_json_metadata
      end
    end
  end
end
