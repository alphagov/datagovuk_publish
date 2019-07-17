class ReindexService
  attr_reader :logger, :index_alias, :indexer, :alias_updater, :index_deleter

  def initialize(args)
    @indexer = args[:indexer]
    @alias_updater = args[:alias_updater]
    @index_deleter = args[:index_deleter]
    @logger = args[:logger]
  end

  def run
    logger.info ">>> Indexing app/services/reindex_service.rb - run >  #{published_datasets_count} datasets"
    indexer.run
    alias_updater.run
    index_deleter.run
    logger.info 'Reindexing complete!'
  end

private

  def published_datasets_count
    Dataset.published.count
  end
end
