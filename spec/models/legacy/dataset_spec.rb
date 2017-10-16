require 'rails_helper'

describe Legacy::Dataset do
  describe "#metadata" do
    it "returns legacy dataset metadata formatted for CKAN" do
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
        'unpublished' => !dataset.published?,
        'metadata_created' => dataset.created_at,
        'metadata_modified' => dataset.last_updated_at,
        'geographic_coverage' => [dataset.location1.to_s.downcase],
        'license_id' => dataset.licence,
        'update_frequency-other' => 'daily'
      }.to_json

      expect(legacy_dataset.json_metadata).to eql legacy_dataset_json_metadata
    end
  end
end
