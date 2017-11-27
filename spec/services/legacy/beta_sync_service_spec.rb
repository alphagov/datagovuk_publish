require 'rails_helper'
require 'util/metadata_tools'

describe Legacy::LegacyToBetaSyncService do
  before do
    @orgs_cache = Organisation.all.pluck(:uuid, :id).to_h
    @theme_cache = Theme.all.pluck(:title, :id).to_h
    @modified_datasets_path = 'api/3/action/package_search?q=metadata_modified:[NOW-1DAY%20TO%20NOW]&rows=5000'
    @new_datasets_path = 'api/3/action/package_search?q=metadata_created:[NOW-1DAY%20TO%20NOW]&rows=5000'
    @legacy_server = double('legacy_server', fetch: '')
    @logger = double('logger', info: '')

    @beta_sync_service = Legacy::LegacyToBetaSyncService.new(
      orgs_cache: @orgs_cache,
      theme_cache: @theme_cache,
      logger: @logger,
      legacy_server: @legacy_server
    )
  end

  describe 'There are modified and new legacy datasets to be imported' do
    it 'Imports legacy datasets' do
      package = {someDataset: {name: 'Awesome data'}}
      response = {'result'=> {'results' => [package]}}
      first_dataset = double('first dataset')
      second_dataset = double('second dataset')

      allow(@legacy_server).to receive(:get).and_return(response)
      allow(Dataset).to receive(:find_by).and_return([first_dataset, second_dataset])
      allow(MetadataTools).to receive(:persist)
      allow(MetadataTools).to receive(:index)

      @beta_sync_service.run

      expect(@legacy_server)
        .to have_received(:get)
              .with(@modified_datasets_path)
              .once

      expect(@legacy_server)
        .to have_received(:get)
              .with(@new_datasets_path)
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
        response = {'result' => {'results' => []}}

        allow(@legacy_server).to receive(:get).and_return(response)
        allow(MetadataTools).to receive(:persist)
        allow(MetadataTools).to receive(:index)

        @beta_sync_service.run

        expect(@legacy_server)
          .to have_received(:get)
                .with(@modified_datasets_path)
                .once

        expect(@legacy_server)
          .to have_received(:get)
                .with(@new_datasets_path)
                .once

        expect(MetadataTools)
          .to_not have_received(:persist)

        expect(MetadataTools)
          .to_not have_received(:index)
      end
    end
  end
end
