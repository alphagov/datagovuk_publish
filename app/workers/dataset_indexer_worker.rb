class DatasetIndexerWorker
  include Sidekiq::Worker
  sidekiq_options queue: :indexer, retry: false

  def perform(datasets, index_name)
    Dataset.__elasticsearch__.client.bulk(
      index: index_name,
      type: ::Dataset.__elasticsearch__.document_type,
      body: datasets
    )
  end
end
