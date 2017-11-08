class LegacyUpdateWorker
  include Sidekiq::Worker

  def perform(url, payload, headers)
    if ENV['LEGACY_API_KEY']
      begin
        RestClient.post(url, payload, headers)
      rescue => e
        Rails.logger.error "Failed to send update request to Legacy with error: #{e.message}"
        raise e
      end
    else
      Rails.logger.warn "No legacy api key environment variable found. Skipping sync."
    end
  end

end
