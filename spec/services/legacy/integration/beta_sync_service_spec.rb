require 'rails_helper'

describe Legacy::BetaSyncService do
  before do
    @modified_datasets_path = 'api/3/action/package_search?q=metadata_modified:[NOW-1DAY%20TO%20NOW]&rows=5000'
    @new_datasets_path = 'api/3/action/package_search?q=metadata_created:[NOW-1DAY%20TO%20NOW]&rows=5000'

    @orgs_cache = Organisation.all.pluck(:uuid, :id).to_h
    @theme_cache = Theme.all.pluck(:title, :id).to_h
    @legacy_server = double(:legacy_server)
    @logger = double(:logger, info: true)

    @beta_sync_service = Legacy::BetaSyncService.new(
      orgs_cache: @orgs_cache,
      theme_cache: @theme_cache,
      logger: @logger,
      legacy_server: @legacy_server
    )
  end

  describe 'There are modified and new legacy datasets to be imported' do
    it 'Imports legacy datasets' do
      id_for_first_legacy_dataset = 1
      id_for_second_legacy_dataset = 2

      first_legacy_dataset = {'name'  => 'Awesome data', 'id' => id_for_first_legacy_dataset}
      second_legacy_dataset = {'name' => 'More awesome data', 'id' => id_for_second_legacy_dataset}

      first_response = {'result'=> {'results' => [first_legacy_dataset]}}
      second_response = {'result'=> {'results' => [second_legacy_dataset]}}

      dataset_import_service = double(:dataset_importer_service, run: true)
      dataset_index_service = double(:dataset_indexer_service, index: true)

      allow(@legacy_server).to receive(:get).and_return(first_response, second_response)

      expect(Legacy::DatasetImportService).to receive(:new)
                                                .with(first_legacy_dataset, @orgs_cache, @theme_cache)
                                                .once
                                                .and_return(dataset_import_service)

      expect(Legacy::DatasetImportService).to receive(:new)
                                                .with(second_legacy_dataset, @orgs_cache, @theme_cache)
                                                .once
                                                .and_return(dataset_import_service)

      expect(Legacy::DatasetIndexService).to receive(:new)
                                               .twice
                                               .and_return(dataset_index_service)


      @beta_sync_service.run

      expect(@legacy_server)
        .to have_received(:get)
              .with(@modified_datasets_path)
              .once

      expect(@legacy_server)
        .to have_received(:get)
              .with(@new_datasets_path)
              .once

      expect(dataset_import_service)
        .to have_received(:run).twice

      expect(dataset_index_service)
        .to have_received(:index)
              .with(id_for_first_legacy_dataset)
              .once

      expect(dataset_index_service)
        .to have_received(:index)
              .with(id_for_second_legacy_dataset)
              .once

    end

    describe 'there are no modified or new datasets to be imported' do
      it 'does not import legacy datasets' do
        response = {'result' => {'results' => []}}

        allow(@legacy_server).to receive(:get).and_return(response)

        @beta_sync_service.run

        expect(@legacy_server)
          .to have_received(:get)
                .with(@modified_datasets_path)
                .once

        expect(@legacy_server)
          .to have_received(:get)
                .with(@new_datasets_path)
                .once

        expect_any_instance_of(Legacy::DatasetImportService).to_not receive(:run)

        expect_any_instance_of(Legacy::DatasetIndexService).to_not receive(:index)
      end
    end
  end
end
