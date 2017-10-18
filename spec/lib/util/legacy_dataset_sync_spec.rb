require 'rails_helper'
require 'util/legacy_dataset_sync'

describe LegacyDatasetSync do
  it 'Imports legacy datasets' do
    orgs_cache =  Organisation.all.pluck(:uuid, :id).to_h
    theme_cache = Theme.all.pluck(:title, :id).to_h

    host = 'http://www.legacyServer.com'
    path = 'api/3/action/package_search?q=metadata_modified:%5BNOW-1DAY%20TO%20NOW%5D&rows=5000'
    url = URI.join(host, path)
    package =  JSON.generate someDataset: { name: 'Awesome data' }
    response = JSON.generate(result: { results: [package] })
    dataset_id = 2
    legacy_dataset_sync = LegacyDatasetSync.new(
      orgs_cache: orgs_cache,
      theme_cache: theme_cache,
      host: host,
      logger: double('logger', info: '')
    )

    stub_request(:get, url).to_return(status: 200, body: response)
    allow(MetadataTools).to receive(:add_dataset_metadata).and_return(dataset_id)
    allow(PublishingWorker).to receive(:perform_async)

    legacy_dataset_sync.run

    expect(WebMock)
      .to have_requested(:get, url)
      .once

    expect(MetadataTools)
      .to have_received(:add_dataset_metadata)
      .with(package, orgs_cache, theme_cache)


    expect(PublishingWorker)
      .to have_received(:perform_async)
      .with(dataset_id)
  end
end
