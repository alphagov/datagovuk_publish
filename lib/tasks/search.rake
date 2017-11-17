namespace :search do
  desc "Reindex all datasets"
  task :reindex, [:batch_size] => :environment do |_, args|
    batch_size = args.batch_size || 50
    logger = Logger.new(STDOUT)
    client = Dataset.__elasticsearch__.client

    betaReindexService = ReindexService.new(
      client: client,
      logger: logger,
      batch_size: batch_size
    )

    betaReindexService.run
  end
end
