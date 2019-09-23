namespace :search do
  desc "Reindex all datasets"
  task :reindex, [:batch_size] => :environment do |_, args|
    batch_size = args.batch_size.nil? ? 50 : args.batch_size.to_i
    logger = Rails.logger
    client = Dataset.__elasticsearch__.client
    date = Time.zone.now.strftime("%Y%m%d%H%M%S")
    index_alias = ENV["ES_INDEX"] || "datasets-#{Rails.env}"
    legacy_index = index_alias
    new_index_name = "#{Dataset.index_name}_#{date}"

    indexer_args = {
      batch_size: batch_size,
      date: date,
      new_index_name: new_index_name,
      client: client,
      logger: logger,
    }

    alias_updater_args = {
      new_index_name: new_index_name,
      index_alias: index_alias,
      client: client,
      logger: logger,
    }

    index_deleter_args = {
      index_alias: index_alias,
      client: client,
      logger: logger,
    }

    indexer = DatasetsIndexerService.new(indexer_args)
    alias_updater = AliasUpdaterService.new(alias_updater_args)
    index_deleter = IndexDeletionService.new(index_deleter_args)

    reindex_service = ReindexService.new(
      indexer: indexer,
      alias_updater: alias_updater,
      index_deleter: index_deleter,
      logger: logger,
    )

    check_for_legacy_index(client, legacy_index)
    reindex_service.run
  end

  def check_for_legacy_index(client, legacy_index)
    indexes = client.indices.get_aliases.keys

    if indexes.include?(legacy_index)
      msg = "An alias can not be assigned to index of the same name. Please delete index '#{legacy_index}' before continuing."
      Raven.capture_exception msg
      raise msg
    end
  end
end
