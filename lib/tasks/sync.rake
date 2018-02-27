namespace :sync do
  desc 'Sync modified or new datasets from legacy to beta'
  task beta: :environment do |_, args|
    orgs_cache =  Organisation.all.pluck(:uuid, :id).to_h
    topic_cache = Topic.all.pluck(:name, :id).to_h

    args = {
      orgs_cache: orgs_cache,
      topic_cache: topic_cache,
      logger: Logger.new(STDOUT),
      legacy_server: Legacy::Server
    }

    legacy_dataset_sync = Legacy::BetaSyncService.new(args)

    legacy_dataset_sync.run
  end
end
