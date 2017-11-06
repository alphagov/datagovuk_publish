require 'rails_helper'
require 'util/legacy_dataset_sync'

describe LegacyDatasetSync do
  before do
    @orgs_cache =  Organisation.all.pluck(:uuid, :id).to_h
    @theme_cache = Theme.all.pluck(:title, :id).to_h
    @host = 'https://test.data.gov.uk'
    modified_datasets_query = '/api/3/action/package_search?q=metadata_modified:[NOW-1DAY%20TO%20NOW]'
    new_datasets_query = '/api/3/action/package_search?q=metadata_created:[NOW-1DAY%20TO%20NOW]'
    @modified_datasets_url = URI.join(@host, modified_datasets_query)
    @new_datasets_url = URI.join(@host, new_datasets_query)
  end

  describe 'There are modified and new legacy datasets to be imported' do
    it 'Imports legacy datasets' do
      package =  JSON.generate someDataset: { name: 'Awesome data' }
      response = JSON.generate(result: { results: [package] })

      first_dataset = double('first dataset')
      second_dataset = double('second dataset')

      legacy_dataset_sync = LegacyDatasetSync.new(
        orgs_cache: @orgs_cache,
        theme_cache: @theme_cache,
        host: @host,
        logger: double('logger', info: '')
      )

      stub_request(:get, @modified_datasets_url).to_return(status: 200, body: response)
      stub_request(:get, @new_datasets_url).to_return(status: 200, body: response)

      allow(Dataset).to receive(:find_by).and_return([first_dataset, second_dataset])
      allow(MetadataTools).to receive(:persist)
      allow(MetadataTools).to receive(:index)

      legacy_dataset_sync.run

      expect(WebMock)
        .to have_requested(:get, @modified_datasets_url)
              .once

      expect(WebMock)
        .to have_requested(:get, @new_datasets_url)
              .once

      expect(MetadataTools)
        .to have_received(:persist)
              .exactly(2).times
              .with(package, @orgs_cache, @theme_cache)

      expect(MetadataTools)
        .to have_received(:index)
              .exactly(2).times
              .with(package)
    end

    describe 'there are no modified or new datasets to be imported' do
      it 'does not import legacy datasets' do
        response = JSON.generate(result: { results: [] })

        legacy_dataset_sync = LegacyDatasetSync.new(
          orgs_cache: @orgs_cache,
          theme_cache: @theme_cache,
          host: @host,
          logger: double('logger', info: '')
        )

        stub_request(:get, @modified_datasets_url).to_return(status: 200, body: response)
        stub_request(:get, @new_datasets_url).to_return(status: 200, body: response)

        allow(MetadataTools).to receive(:persist)
        allow(MetadataTools).to receive(:index)

        legacy_dataset_sync.run

        expect(WebMock)
          .to have_requested(:get, @modified_datasets_url)
                .once

        expect(WebMock)
          .to have_requested(:get, @new_datasets_url)
                .once

        expect(MetadataTools)
          .to_not have_received(:persist)

        expect(MetadataTools)
          .to_not have_received(:index)
      end
    end
  end
end
