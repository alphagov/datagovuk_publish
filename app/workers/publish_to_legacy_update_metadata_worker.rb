require 'rest-client'

class PublishToLegacyUpdateMetadataWorker
  include Sidekiq::Worker

  def perform(id)
    dataset = Dataset.find(id)
    Legacy::Dataset.new(dataset).update
  end

end
