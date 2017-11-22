namespace :search do
  desc "Reindex all datasets"
  task :reindex, [:batch_size] => :environment do |_, args|
    batch_size = args.batch_size.to_i || 50
    logger = Logger.new(STDOUT)
    client = Dataset.__elasticsearch__.client
    date = Time.now.strftime('%Y%m%d%H%M%S')
    index_alias = "datasets-#{ENV['RAILS_ENV']}"
    new_index_name = "#{Dataset.index_name}_#{date}"

    indexer_args = {
      batch_size: batch_size,
      date: date,
      new_index_name: new_index_name,
      client: client,
      logger: logger
    }

    alias_updater_args = {
      new_index_name: new_index_name,
      index_alias: index_alias,
      client: client,
      logger: logger
    }

    index_deleter_args = {
      index_alias: index_alias,
      client: client,
      logger: logger
    }

    indexer = DatasetsIndexerService.new(indexer_args)
    alias_updater = AliasUpdaterService.new(alias_updater_args)
    index_deleter = IndexDeletionService.new(index_deleter_args)

    reindexService = ReindexService.new(
      indexer: indexer,
      alias_updater: alias_updater,
      index_deleter: index_deleter,
      logger: logger,
    )

    reindexService.run
  end
end
