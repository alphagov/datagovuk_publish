require 'rails_helper'

describe Legacy::Datafile do
  it "#datafile_json" do
    datafile = FactoryGirl.create(:datafile, format: 'csv', )
    legacy_datafile = Legacy::Datafile.new(datafile)
    ckanified_json = {
      'id' => datafile.uuid,
      'name' => datafile.name,
      'format' => datafile.format,
      'resource_type' => 'file',
      'url' => datafile.url,
      'created' => datafile.created_at
    }.to_json

    expect(ckanified_json).to eq legacy_datafile.datafile_json
  end
end
