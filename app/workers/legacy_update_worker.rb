class LegacyUpdateWorker
  include Sidekiq::Worker

  def perform(url, payload, headers)
    begin
      RestClient.post(url, payload, headers)
    rescue => e
      Rails.logger.error "Failed to send update request to Legacy with error: #{e.message}"
      raise e
    end
  end
end
