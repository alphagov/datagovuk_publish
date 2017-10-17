require 'rails_helper'
require './lib/util/legacy_dataset_sync'

describe LegacyDatasetSync do
  it 'Imports legacy datasets' do
    orgs_cache =  Organisation.all.pluck(:uuid, :id).to_h
    theme_cache = Theme.all.pluck(:title, :id).to_h

    host = 'www.legacyServer.com'
    path = '/api/3/action/package_search?q=metadata_modified:%5BNOW-1DAY%20TO%20NOW%5D&rows=5000'
    url = "http://#{host}#{path}"
    package =  JSON.generate someDataset: { name: 'Awesome data' }
    response = JSON.generate(result: { results: [package] })
    legacy_dataset_sync = LegacyDatasetSync.new(
      orgs_cache: orgs_cache,
      theme_cache: theme_cache,
      host: host
    )

    stub_request(:get, url).to_return(status: 200, body: response)
    allow(MetadataTools).to receive(:add_dataset_metadata)

    legacy_dataset_sync.run

    WebMock
      .should have_requested(:get, url)
      .once

    expect(MetadataTools)
      .to have_received(:add_dataset_metadata)
      .with(package, orgs_cache, theme_cache)
  end
end
