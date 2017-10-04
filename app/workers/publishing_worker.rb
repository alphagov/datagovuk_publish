class PublishingWorker
  include Sidekiq::Worker

  def perform(dataset_id)
    dataset = Dataset.find(dataset_id)

    logger.info "Attempting to publish dataset #{dataset.id}"
    dataset.__elasticsearch__.index_document
  end
end
