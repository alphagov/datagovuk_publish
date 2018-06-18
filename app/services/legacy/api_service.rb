class Legacy::APIService
  PUBLISHER_SHOW_PATH = '/api/3/action/publisher_show'.freeze

  def publisher_show(publisher_id)
    call_api(PUBLISHER_SHOW_PATH, id: publisher_id)
  end

private

  def build_url(path)
    host = ENV.fetch("LEGACY_HOST", "https://data.gov.uk")
    URI.join(host, path).to_s
  end

  def call_api(path, parameters)
    url = build_url(path)

    begin
      api_parameters = { params: parameters }
      api_response = RestClient.get url, api_parameters
    rescue RestClient::ExceptionWithResponse => e
      Rails.logger.error "Request to API to retrieve #{parameters[:id]} responded with: #{e.response.code}"
      return nil
    rescue SocketError => _
      Rails.logger.error "Connection error with #{url}"
      return nil
    end

    JSON.parse(api_response).fetch('result')
  end
end
