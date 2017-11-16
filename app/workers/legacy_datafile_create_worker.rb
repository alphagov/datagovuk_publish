class LegacyDatafileCreateWorker
  include Sidekiq::Worker

  def perform(datafile_id)
    datafile = Datafile.find(datafile_id)
    url = Legacy::Server.url_for(resource_name: "datafile", action: "create")
    payload = Legacy::Datafile.new(datafile).payload
    headers = Legacy::Server.headers

    if ENV['LEGACY_API_KEY']
      begin
        RestClient.post(url, payload, headers)
      rescue => error
        Raven.capture_exception(error, extra: { payload: payload, url: url, headers: headers })
        Rails.logger.error "Failed to create datafile with uuid:#{datafile.uuid} on Legacy with error: #{error.message}"
      end
    else
      Rails.logger.warn "No legacy api key environment variable found. Skipping sync."
    end
  end
end
