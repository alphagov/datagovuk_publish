class Legacy::APIService
  PACKAGE_SEARCH_PATH = '/api/3/action/package_search'.freeze
  PACKAGE_SHOW_PATH = '/api/3/action/package_show'.freeze
  PUBLISHER_SHOW_PATH = '/api/3/action/publisher_show'.freeze

  def dataset_show(dataset_id)
    call_api(PACKAGE_SHOW_PATH, id: dataset_id)
  end

  def dataset_search(query, field_query = '', limit = 1000, offset = 0)
    call_api(PACKAGE_SEARCH_PATH, q: query, fq: field_query, rows: limit, start: offset)
  end

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
