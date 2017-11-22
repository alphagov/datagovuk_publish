require 'rails_helper'

describe ReindexService do
  it 'Reindexes' do
    logger_double = double('logger', info: '')
    indexer_double = double('indexer', run: true)
    alias_updater_double = double('alias_updater', run: true)
    index_deleter_double = double('index_deleter', run: true)

    reindexer_service_args = {
      batch_size: 50,
      indexer: indexer_double,
      alias_updater: alias_updater_double,
      index_deleter: index_deleter_double,
      logger: logger_double
    }

    reindex_service = ReindexService.new(reindexer_service_args)

    reindex_service.run

    [indexer_double, alias_updater_double, index_deleter_double].each do |double|
      expect(double).to have_received(:run).once
    end
  end
end
