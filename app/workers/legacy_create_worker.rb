class LegacyCreateWorker
  include Sidekiq::Worker

  def perform(dataset_id)
    dataset = Dataset.find(dataset_id)
    url = Legacy::Server.new.create_legacy_dataset_url
    headers = Legacy::Server.new.headers
    payload = Legacy::Dataset.new(dataset).create_payload

    if ENV['LEGACY_API_KEY']
      begin
        response = RestClient.post(url, payload, headers)
        body = JSON.parse(response.body)
        dataset.update(ckan_uuid: body["result"]["id"])
      rescue => error
        Raven.capture_exception(error, extra: { payload: payload, url:url, headers:headers })
        Rails.logger.error "Failed to send update request to Legacy with error: #{error.message}"
      end
    else
      Rails.logger.warn "No legacy api key environment variable found. Skipping sync."
    end

  end
end
