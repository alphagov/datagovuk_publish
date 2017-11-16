require 'rails_helper'

describe Legacy::Datafile do
  describe '#payload' do
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

      expect(legacy_datafile.payload).to eq legacy_datafile_json
    end
  end
end
