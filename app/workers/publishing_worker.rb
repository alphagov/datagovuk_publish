class PublishingWorker
  include Sidekiq::Worker

  def perform(dataset_id)
    dataset = Dataset.find(dataset_id)

    if dataset.publishable?
      logger.info "Attempting to publish dataset #{dataset.id}"
      dataset.__elasticsearch__.index_document
    end
  end
end
