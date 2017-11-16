require 'rails_helper'

describe Legacy::Dataset do
  it "name is impervious to any Publish Beta dataset title changes" do
    url = "https://test.data.gov.uk/api/3/action/package_patch"
    stub_request(:any, url).to_return(status: 200)

    publish_beta_dataset = FactoryGirl.create(:dataset, title: "Foo Bar", legacy_name: "bar-baz")
    legacy_dataset = Legacy::Dataset.new(publish_beta_dataset)

    publish_beta_dataset.update(title: "Bam Boom")

    expect(JSON.parse(legacy_dataset.update_payload)["name"]).to eql(publish_beta_dataset.legacy_name)
  end

  describe "#update_payload" do
    it "outputs json for legacy" do
       dataset = FactoryGirl.create(:dataset, frequency: 'daily', ckan_uuid: '123abc')
       legacy_dataset = Legacy::Dataset.new(dataset)

       legacy_dataset_json_metadata = {
         'id': dataset.ckan_uuid,
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
                       "value" => 'daily'},
                      {"key" => "update_frequency-other",
                       "value" => 'daily'}
                     ],
         'unpublished' => !dataset.published?,
         'metadata_modified' => dataset.last_updated_at,
         'geographic_coverage' => [dataset.location1.to_s.downcase],
         'license_id' => dataset.licence
       }.to_json
       expect(legacy_dataset.update_payload).to eql legacy_dataset_json_metadata
    end
  end

  describe "#create_payload" do
    it "outputs json for legacy" do
       dataset = FactoryGirl.create(:dataset, frequency: 'daily')
       legacy_dataset = Legacy::Dataset.new(dataset)

       legacy_dataset_json = {
         'name' => dataset.name,
         'title' => dataset.title,
         'notes' => dataset.summary,
         'description' => dataset.summary,
         'owner_org' => dataset.organisation.uuid,
         'update_frequency' => 'daily',
         'update_frequency-other' => 'daily',
         'extras' => [{"key" => "update_frequency",
                       "value" => 'daily'},
                      {"key" => "update_frequency-other",
                       "value" => 'daily'},
                       {"key" => "publish_uuid",
                        "value" => dataset.uuid}
                     ],
         'geographic_coverage' => [dataset.location1.to_s.downcase],
         'license_id' => dataset.licence
       }.to_json
       expect(legacy_dataset.create_payload).to eql legacy_dataset_json
    end
  end

end
