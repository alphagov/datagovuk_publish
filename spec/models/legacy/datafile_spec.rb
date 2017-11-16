require 'rails_helper'

describe Legacy::Datafile do
  describe '#update_payload' do
    it "outputs json for legacy" do
      datafile = FactoryGirl.create(:link)
      legacy_datafile = Legacy::Datafile.new(datafile)

      legacy_datafile_json = {
        id: datafile.uuid,
        description: datafile.name,
        format: datafile.format,
        date: "",
        resource_type: "file",
        url: datafile.url,
        created: datafile.created_at
      }.to_json

      expect(legacy_datafile.update_payload).to eq legacy_datafile_json
    end
  end

  describe '#create_payload' do
    it "outputs json for legacy" do
      datafile = FactoryGirl.create(:link, size: 2)
      dataset = FactoryGirl.create(:dataset, ckan_uuid: '123', links: [datafile])
      legacy_datafile = Legacy::Datafile.new(datafile)

      legacy_datafile_json = {
        package_id: datafile.dataset.ckan_uuid,
        url: datafile.url,
        description: datafile.name,
        format: datafile.format,
        name: datafile.name,
        resource_type: "file",
        size: datafile.size,
        created: datafile.created_at
      }.to_json
      expect(legacy_datafile.create_payload).to eq legacy_datafile_json
    end
  end
end
