require 'rest-client'

class LegacySyncWorker
  include Sidekiq::Worker

  def perform(id)
    dataset = Dataset.find(id)
    Legacy::Dataset.new(dataset).update
  end
end
