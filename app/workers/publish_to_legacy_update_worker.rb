require 'rest-client'

class PublishToLegacyUpdateWorker
  include Sidekiq::Worker

  def perform(id)
    if ENV['LEGACY_HOST'] && ENV['LEGACY_API_KEY']
      dataset = Dataset.find(id)
      Legacy::Dataset.new(dataset).update
    else
      Rails.logger.warn "No legacy environment variables found. Skipping sync."
    end
  end

end
