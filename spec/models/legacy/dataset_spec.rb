require 'rails_helper'

describe Legacy::Dataset do
  it "name is impervious to any Publish Beta dataset title changes" do
    url = "https://test.data.gov.uk/api/3/action/package_patch"
    stub_request(:any, url).to_return(status: 200)

    publish_beta_dataset = FactoryGirl.create(:dataset, title: "Foo Bar", legacy_name: "bar-baz")
    legacy_dataset = Legacy::Dataset.new(publish_beta_dataset)

    publish_beta_dataset.update(title: "Bam Boom")

    expect(JSON.parse(legacy_dataset.payload)["name"]).to eql(publish_beta_dataset.legacy_name)
  end

  describe "#payload" do
    it "outputs json for legacy" do
       dataset = FactoryGirl.create(:dataset, frequency: 'daily')
       legacy_dataset = Legacy::Dataset.new(dataset)

       legacy_dataset_json_metadata = {
         'id' => dataset.uuid,
         'name' => dataset.legacy_name,
         'title' => dataset.title,
         'notes' => dataset.summary,
         'description' => dataset.summary,
         'organization' => {
           'name' => dataset.organisation.name
         },
         'update_frequency' => 'daily',
         'update_frequency-other' => 'daily',
         'extras' => [{"key" => "update_frequency",
                       "package_id" => dataset.uuid,
                       "value" => 'daily'},
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

       expect(legacy_dataset.payload).to eql legacy_dataset_json_metadata
    end
  end
end
