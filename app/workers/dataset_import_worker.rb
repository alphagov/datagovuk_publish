class DatasetImportWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :importer, :retry => false

  def perform(legacy_dataset, orgs_cache, theme_cache)
    Legacy::DatasetImportService.new(legacy_dataset, orgs_cache, theme_cache).run
  end
end
