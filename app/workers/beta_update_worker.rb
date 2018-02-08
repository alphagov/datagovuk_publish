class BetaUpdateWorker
  include Sidekiq::Worker
  sidekiq_options queue: :indexer, retry: false

  attr_writer :logger

  def logger
    @logger || super
  end

  def perform
    orgs_cache = Organisation.pluck(:uuid, :id).to_h
    topic_cache = Topic.pluck(:name, :id).to_h

    Legacy::BetaSyncService
      .new(
        orgs_cache: orgs_cache,
        topic_cache: topic_cache,
        legacy_server: Legacy::Server,
        logger: logger,
        )
      .run
  end
end
