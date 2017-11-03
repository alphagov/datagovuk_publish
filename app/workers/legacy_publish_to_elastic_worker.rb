class LegacyPublishToElasticWorker
  include Sidekiq::Worker

  def perform(dataset)
    logger.info "Attempting to publish dataset #{dataset.id}"
    dataset.__elasticsearch__.index_document
  end
end
