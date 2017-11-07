require 'rest-client'
require 'util/legacy_dataset_sync'

namespace :sync do
  desc 'Synchronise datasets from Legacy DGU'
  task legacy: :environment do |_, args|
    orgs_cache =  Organisation.all.pluck(:uuid, :id).to_h
    theme_cache = Theme.all.pluck(:title, :id).to_h
    host = Rails.env.production? ? 'https://data.gov.uk/' : 'https://test.data.gov.uk/'

    legacy_dataset_sync = LegacyDatasetSync.new(
      orgs_cache: orgs_cache,
      theme_cache: theme_cache,
      host: host,
      logger: Logger.new(STDOUT)
    )

    legacy_dataset_sync.run
  end
end
