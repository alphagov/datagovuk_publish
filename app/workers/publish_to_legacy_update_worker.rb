require 'rest-client'

class PublishToLegacyUpdateWorker
  include Sidekiq::Worker

  def perform(id)
    dataset = Dataset.find(id)
    Legacy::Dataset.new(dataset).update
  end

end
