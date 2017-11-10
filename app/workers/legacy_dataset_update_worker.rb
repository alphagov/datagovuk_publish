class LegacyDatasetUpdateWorker
  include Sidekiq::Worker

  def perform(dataset_id)
    dataset = Dataset.find(dataset_id)
    url = Legacy::Server.new.update_legacy_dataset_url
    payload = Legacy::Dataset.new(dataset).update_payload
    headers = Legacy::Server.new.headers

    if ENV['LEGACY_API_KEY']
      begin
        RestClient.post(url, payload, headers)
      rescue => error
        Raven.capture_exception(error, extra: { payload: payload, url:url, headers:headers })
        Rails.logger.error "Failed to send update request to Legacy with error: #{error.message}"
      end
    else
      Rails.logger.warn "No legacy api key environment variable found. Skipping sync."
    end
  end
end
